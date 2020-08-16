#!/bin/python3

import json
from pathlib import Path
import os
from typing import Dict, List

from logless import get_logger, logged_block
import runnow
import uio

from templates import DOCS_HEADER, DOCS_FOOTER, CATALOG_TEMPLATE

logging = get_logger("infra-catalog.build")

SPECIAL_CASE_WORDS = [
    "AWS",
    "ECR",
    "ECS",
    "IAM",
    "VPC",
    "DBT",
    "EC2",
    "RDS",
    "MySQL",
    "ML",
    "MLOps",
    "SFTP",
]


def main():
    """Rebuild docs."""
    build_catalog_index()
    build_component_index()
    update_module_docs("../catalog")
    update_module_docs("../components")


def build_catalog_index():
    build_index(
        "Catalog",
        tf_dir="../catalog",
        output_file="../catalog/README.md",
        overview_desc=(
            "The Infrastructure Catalog contains ready-to-deploy terraform modules for "
            "a variety of production data project use cases and POCs. For information "
            "about the technical building blocks used in these modules, please see the "
            "catalog [components index](../components/README.md)."
        ),
    )


def build_component_index():
    build_index(
        "Components",
        tf_dir="../components",
        output_file="../components/README.md",
        overview_desc=(
            "These components define the technical building blocks which enable "
            "advanced, ready-to-deploy data solutions in the "
            "[Infrastructure Catalog](../catalog/README.md)."
        ),
    )


def _proper(str: str, title_case=True, special_case_words=None):
    """
    Return the same string in proper case, respected override rules for
    acronyms and special-cased words.
    """
    special_case_words = special_case_words or SPECIAL_CASE_WORDS
    word_lookup = {w.lower(): w for w in special_case_words}
    if title_case:
        str = str.title()
    words = str.split(" ")
    new_words = []
    for word in words:
        new_subwords = []
        for subword in word.split("-"):
            new_subwords.append(word_lookup.get(subword.lower(), subword))
        new_word = "-".join(new_subwords)
        new_words.append(new_word)
    return " ".join(new_words)


def build_index(index_type: str, tf_dir: str, output_file: str, overview_desc: str):
    """
    Update the documentation index.

    Parameters:
    ----------
    index_type (str): Either 'Components' or 'Catalog'.
    tf_dir (str): The directory to scan for modules.
    output_file (str): The location of the documentation file to create.
    overview_dsc (str): The overview that will appear at the top of the index.
    """
    content_metadata = {
        "aws": "",
        # "azure": "",
        # "gcp": "",
    }
    git_url_pattern = "git::{git_repo}/{path}?ref={branch}"
    git_repo = "https://github.com/slalom-ggp/dataops-infra"
    git_branch = "main"

    toc_str = ""
    for platform_i, platform in enumerate(content_metadata.keys(), start=1):
        toc_str += (
            f"{platform_i}. [{_proper(platform)} {index_type}]"
            f"(#{platform.lower()}-{index_type.lower()})\n"
        )

        logging.info(f"Exploring platform '{platform}'")
        catalog_modules = get_tf_metadata(f"{tf_dir}/{platform}", recursive=True)
        for module, metadata in catalog_modules.items():
            module_title = f"{_proper(platform)} {_proper(os.path.basename(module))}"
            toc_str += (
                f"    - [{module_title}](#{module_title.replace(' ', '-').lower()})\n"
            )
            logging.debug(f"Exploring module '{module}': {metadata}")
            readme_path = f"{module}/README.md"
            content_metadata[platform] += (
                f"### {module_title}\n\n"
                f"#### Overview\n\n"
                f"{metadata['header']}\n\n"
                f"#### Documentation\n\n"
                f"- [{module_title} Readme]({readme_path})\n\n"
                f"-------------------\n\n"
            )
    content = CATALOG_TEMPLATE.format(
        toc=toc_str,
        aws=content_metadata["aws"],
        azure="_(Coming soon)_",
        gcp="_(Coming soon)_",
        index_type=index_type,
        overview=overview_desc,
    )
    uio.create_text_file(output_file, content)


def update_module_docs(
    tf_dir: str,
    *,
    recursive: bool = True,
    readme: str = "README.md",
    footer: bool = True,
    header: bool = True,
    special_case_words: List[str] = None,
    extra_docs_names: List[str] = ["USAGE.md", "NOTES.md"],
    git_repo: str = "https://github.com/slalom-ggp/dataops-infra",
) -> None:
    """
    Replace all README.md files with auto-generated documentation

    This is a wrapper around the `terraform-docs` tool.

    Parameters
    ----------
    tf_dir : str
        Directory of terraform scripts to document.
    recursive : bool, optional
        Run on all subdirectories, recursively. By default True.
    readme : str, optional
        The filename to create when generating docs, by default "README.md".
    footer : bool, optional
        Include the standard footnote, by default True.
    header : bool, optional
        Include the standard footnote, by default True.
    special_case_words : List[str], optional
        A list of words to override special casing rules, by default None.
    extra_docs_names : List[str], optional
        A list of filenames which, if found, will be appended to each
        module's README.md file, by default ["USAGE.md", "NOTES.md"].
    git_repo : str, optional
        The git repo path to use in rendering 'source' paths, by
        default "https://github.com/slalom-ggp/dataops-infra".
    """
    markdown_text = ""
    if ".git" not in tf_dir and ".terraform" not in tf_dir:
        tf_files = [x for x in uio.list_files(tf_dir) if x.endswith(".tf")]
        extra_docs = [
            x
            for x in uio.list_files(tf_dir)
            if extra_docs_names and os.path.basename(x) in extra_docs_names
        ]
        if tf_files:
            module_title = _proper(
                os.path.basename(tf_dir), special_case_words=special_case_words
            )
            parent_dir_name = os.path.basename(Path(tf_dir).parent)
            if parent_dir_name != ".":
                module_title = _proper(
                    f"{parent_dir_name} {module_title}",
                    special_case_words=special_case_words,
                )
            module_path = tf_dir.replace(".", "").replace("//", "/").replace("\\", "/")
            _, markdown_output = runnow.run(
                f"terraform-docs markdown document --sort=false {tf_dir}",
                # " --no-requirements"
                echo=False,
            )
            if header:
                markdown_text += DOCS_HEADER.format(
                    module_title=module_title, module_path=module_path
                )
            markdown_text += markdown_output
            for extra_file in extra_docs:
                markdown_text += uio.get_text_file_contents(extra_file) + "\n"
            if footer:
                markdown_text += DOCS_FOOTER.format(
                    src="\n".join(
                        [
                            "* [{file}]({repo}/tree/main/{dir}/{file})".format(
                                repo=git_repo,
                                dir=module_path,
                                file=os.path.basename(tf_file),
                            )
                            for tf_file in tf_files
                        ]
                    )
                )
            uio.create_text_file(f"{tf_dir}/{readme}", markdown_text)
    if recursive:
        for folder in uio.list_files(tf_dir):
            if os.path.isdir(folder):
                update_module_docs(folder, recursive=recursive, readme=readme)


def get_tf_metadata(tf_dir: str, recursive: bool = False, save_to_dir: bool = True):
    """
    Return a dictionary of Terraform module paths to JSON metadata about each module,
    a wrapper around the `terraform-docs` tool.

    Parameters:
    ----------
    tf_dir: Directory of terraform scripts to scan.
    recursive : Optional (default=True). 'True' to run on all subdirectories, recursively.

    Returns:
    -------
    dict
    """
    result = {}
    if (
        ".git" not in tf_dir
        and ".terraform" not in tf_dir
        and "samples" not in tf_dir
        and "tests" not in tf_dir
    ):
        if [x for x in uio.list_files(tf_dir) if x.endswith(".tf")]:
            _, json_text = runnow.run(f"terraform-docs json {tf_dir}", echo=False)
            result[tf_dir] = json.loads(json_text)
            if save_to_dir:
                uio.create_folder(f"{tf_dir}/.terraform")
                uio.create_text_file(
                    f"{tf_dir}/.terraform/terraform-docs.json", json_text
                )
    if recursive:
        for folder in sorted(uio.list_files(tf_dir)):
            folder = folder.replace("\\", "/")
            if os.path.isdir(folder):
                result.update(get_tf_metadata(folder, recursive=recursive))
    return result


def check_tf_metadata(
    tf_dir,
    recursive: bool = True,
    check_module_headers: bool = True,
    check_input_descriptions: bool = True,
    check_output_descriptions: bool = True,
    required_input_vars: list = ["name_prefix", "resource_tags", "environment"],
    required_output_vars: list = ["summary"],
    raise_error=True,
    abspath=False,
):
    """
    Return a dictionary of reference paths to error messages and a dictionary
    of errors to reference paths.
    """

    def _log_issue(module_path, issue_desc, details_list):
        if details_list:
            if issue_desc in error_locations:
                error_locations[issue_desc].extend(details_list)
            else:
                error_locations[issue_desc] = details_list

    error_locations: Dict[str, List[str]] = {}
    with logged_block("checking Terraform modules against repository code standards"):
        modules_metadata = get_tf_metadata(tf_dir, recursive=recursive)
        for module_path, metadata in modules_metadata.items():
            if abspath:
                path_sep = os.path.sep
                module_path = os.path.abspath(module_path)
                module_path = module_path.replace("\\", path_sep).replace("/", path_sep)
            else:
                path_sep = "/"
            if check_module_headers and not metadata["header"]:
                _log_issue(
                    module_path,
                    "1. Blank module headers",
                    [f"{module_path}{path_sep}main.tf"],
                )
            if required_input_vars:
                issue_details = [
                    f"{module_path}{path_sep}variables.tf:var.{required_input}"
                    for required_input in required_input_vars
                    if required_input
                    not in [var["name"] for var in metadata.get("inputs", {})]
                ]
                _log_issue(
                    module_path, "2. Missing required input variables", issue_details
                )
            if required_output_vars:
                issue_details = [
                    f"{module_path}{path_sep}outputs.tf:output.{required_output}"
                    for required_output in required_output_vars
                    if required_output
                    not in [var["name"] for var in metadata.get("outputs", {})]
                ]
                _log_issue(
                    module_path, "3. Missing required output variables", issue_details
                )
            if check_input_descriptions:
                issue_details = [
                    f"{module_path}{path_sep}variables.tf:var.{var['name']}"
                    for var in metadata.get("inputs", {})
                    if not var.get("description")
                ]
                _log_issue(
                    module_path, "4. Missing input variable descriptions", issue_details
                )
            if check_output_descriptions:
                issue_details = [
                    f"{module_path}{path_sep}outputs.tf:output.{var['name']}"
                    for var in metadata.get("outputs", {})
                    if not var.get("description")
                ]
                _log_issue(
                    module_path,
                    "5. Missing output variable descriptions",
                    issue_details,
                )
    result_str = "\n".join(
        [
            f"\n{k}:\n    - [ ] " + ("\n    - [ ] ".join(error_locations[k]))
            for k in sorted(error_locations.keys())
        ]
    )
    if raise_error and error_locations:
        raise ValueError(f"One or more validation errors occurred.\n{result_str}")
    return result_str


if __name__ == "__main__":
    main()
