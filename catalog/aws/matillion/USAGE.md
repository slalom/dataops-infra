## Usage Notes

From the AWS Marketplace offering page:

* `The default username for the Matillion web application is "ec2-user"and the password is initially set to the instance-id.`

## Pricing Notes

* Pricing for Matillion on AWS Marketplace is currently 12K per year times a factor driven
  by size of instance type, then amortized by hour, with the actual cost of the instance
  type playing only a nominal impact. Because the hardware cost is a small fraction of the
  total per-hour software cost, it is advised to select the most powerful instance type
  available for the overall software licensing price point band.
* Instance size also determines some feature availability, such as "Enterprise Mode" features.
  For more information, please see Matillion's
  [Instance Sizes article](https://snowflake-support.matillion.com/s/article/1991961).
* Please note that "[Git Integration](https://snowflake-support.matillion.com/s/article/2974180)"
  is considered an Enterprise Mode feature. For a specific list of features which require
  Enterprise Mode, please see [this article](https://snowflake-support.matillion.com/s/article/2881895).
