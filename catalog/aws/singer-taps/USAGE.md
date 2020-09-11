## Usage

This module supports multiple taps per each target. To target multiple destinations, simply create
additional instances of the module.

### Tap configuration overview

The `taps` input variable expects a list of specifications for each tap. The specification for each
tap should include the following properties:

- `id` - The name or alias of the tap as registered in the [Singer Index](#singer-index), without the `tap-` prefix.
  - Note: in most cases, this is exactly what you'd expect: `mssql` for `tap-mssql`, etc. However,
    for forks or experimental releases, this might contain a suffix such as `mssql-test` for a test
    version of `tap-mssql` or `snowflake-singer` for the singer edition of `tap-snowflake`.
  - A future release will add a separate and optional flag for `owner` or `variant`, in place of the
    currently used alias/suffix convention. See the [Singer Index](#singer-index) section for more
    info.
- `name` - What you want to call the data source. For instance, if you have multiple SQL Servers, you may want to use a more memorable name such as `finance-system` or `gl-db`. This name should still align with tap naming conventions, which is to say it should be in _lower-case-with-dashes_ format.
- `settings` - A simple map of the tap settings' names to their values. These are specific to each tap and they are required for each tap to work.
  - Note: While singer does not distinguish between 'secrets' and 'settings', we should and do treat these two types of config separately. Be sure to put all sensitive config in the `secrets` collection, and not here in `settings`.
- `secrets` - Same as `config` except for sensitive values. When passing secrets, you specify the setting name in the same way but you _must_ either pass the value as a pointer to the file containing the secret (a config.json file, for instance) or else pass a AWS Secrets Manager ARN.
  - _If you pass a Secrets Manager ARN as the config value_, that secret pointer will be passed to the ECS container securely, and only the running container will have access to the secret.
  - _If you pass a pointer to a config file_, the module will automatically create a new AWS Secrets Manager secret, upload the secret to AWS Secrets Manager, and then the above process will continue by passing the Secrets Manager pointer _only_ to the running ECS container.

### Singer Index

There are actually two Singer Indexes currently available.

1. The first and primary index for this module today is the tapdance index stored [here](https://github.com/aaronsteers/tapdance/blob/master/docker/singer_index.yml).

2. This index will be eventually be replaced by a new dedicated [Singer DB](https://github.com/aaronsteers/singer-db), which is still a work-in-progress.

Note:

- Both of these sources support multiple versions (forks) of each tap, and both provide a "default"
  or "recommended" version for those new users who just want to get started quickly.
- The new [Singer DB](https://github.com/aaronsteers/singer-db) will implement a new "owner" or "variant"
  flag to replace the current "alias" technique used by the
  [tapdance index](https://github.com/aaronsteers/tapdance/blob/master/docker/singer_index.yml).
