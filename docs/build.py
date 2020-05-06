import os

from slalom.dataops import io, jobs, infra

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
]

CATALOG_TEMPLATE = """
# DataOps Infrastructure {index_type}

{overview}

## Contents

{toc}
2. Azure {index_type}
    * _(Coming soon)_
2. GCP {index_type}
    * _(Coming soon)_

## AWS {index_type}

{aws}

## Azure {index_type}

{azure}

## GCP {index_type}

{gcp}

-------------------

_**NOTE:** This documentation was [auto-generated](build.py) using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._

"""


def main():
    """Rebuild docs."""
    build_catalog_index()
    build_component_index()
    infra.update_module_docs("..")


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


def _proper(str, title_case=True):
    """
    Return the same string in proper case, respected override rules for "
    acronyms and special-cased words.
    """
    word_lookup = {w.lower(): w for w in SPECIAL_CASE_WORDS}
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
    git_branch = "master"

    toc_str = ""
    for platform_i, platform in enumerate(content_metadata.keys(), start=1):
        toc_str += (
            f"{platform_i}. [{_proper(platform)} {index_type}]"
            f"(#{platform.lower()}-{index_type.lower()})\n"
        )

        print(f"Exploring platform '{platform}'")
        catalog_modules = infra.get_tf_metadata(f"{tf_dir}/{platform}", recursive=True)
        for module, metadata in catalog_modules.items():
            module_title = f"{_proper(platform)} {_proper(os.path.basename(module))}"
            toc_str += (
                f"    - [{module_title}](#{module_title.replace(' ', '-').lower()})\n"
            )
            print(f"Exploring module '{module}': {metadata}")
            source = git_url_pattern.format(
                git_repo=git_repo, path=module.replace(".", ""), branch=git_branch
            )
            readme_path = f"{module}/README.md"
            content_metadata[platform] += (
                f"### [{module_title}]({readme_path})\n\n"
                f"{metadata['header']}\n\n"
                f"* Source: `{source}`\n"
                f"* See the [{module_title} Readme]({readme_path}) for input/output specs and additional info.\n\n"
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
    io.create_text_file(output_file, content)


if __name__ == "__main__":
    main()
