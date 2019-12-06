# aws-tableau.secrets

This folder should contain one `registration.json` file with the following contents:

```json
{
  "eula": "yes",
  "company": "[Slalom]",
  "industry": "Software & Technology",
  "department": "Engineering/Development",
  "country": "USA",
  "city": "[Seattle]",
  "state": "[WA]",
  "zip": "[ZIP]",
  "first_name": "[First]",
  "last_name": "[Last]",
  "title": "[Solution Principal]",
  "phone": "4085551234",
  "email": "my.email@domain.com"
}
```

NOTE:

- Contents of this folder (excepting this readme) will be excluded from git in order to avoid committing personal data (PII) into source control.
