"""Templates"""

DOCS_HEADER = """
# {module_title}

`{module_path}`

## Overview


"""


# TODO: inject into footer:
# ## Import Template

# Copy-paste the below to get started with this module in your own project:

# ```hcl
# module "{clean_name}" {
#     source = "git::{git_repo}/{module_path}?ref=main"

#     // ...
# }
# ```
DOCS_FOOTER = """
---------------------

## Source Files

_Source code for this module is available using the links below._

{src}

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
"""


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

_**NOTE:** This documentation was auto-generated using
`terraform-docs`. Please do not attempt to manually update
this file._

"""
