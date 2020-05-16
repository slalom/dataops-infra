# Setting up the COVID-19 tap

## Configuring GitHub authorization for `tap-covid-19` data extraction

1. Rename the file in the `data/taps/.secrets` folder from `tap-covid-19-config.json.template` to `tap-covid-19-config.json`.
2. Go to [https://github.com/settings/tokens](https://github.com/settings/tokens) and create a new token with the `public_repo` grant.
3. Paste the token into to `api_token` setting in  `tap-covid-19-config.json`.
4. Replace the `user_agent` value with your own name and email.
