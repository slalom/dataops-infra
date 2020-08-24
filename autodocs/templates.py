"""Templates"""

DOCS_HEADER = """---
parent: Infrastructure {module_type}
title: {module_title}
nav_exclude: false
---
# {module_title}

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main{module_path}?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main{module_path})

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


CATALOG_TEMPLATE = """---
title: Infrastructure {index_type}
has_children: true
nav_order: 3
nav_exclude: false
---
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
