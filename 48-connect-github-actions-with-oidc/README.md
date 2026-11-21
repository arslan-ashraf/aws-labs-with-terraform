In this lab, we see how to connect a Github Actions pipeline to AWS.

To run this lab, copy this lab outside of the base directory `aws-labs-with-terraform`.  This is done because Github Actions requires that the CI workflow folder `.github/workflows/` is in the root directory.

In order to run the lab correctly, notice the `values` field in `02-iam-trust-policy.tf` as:
```
values = [
	"repo:arslan-ashraf/48-connect-github-actions-with-oidc:ref:refs/heads/main"
]
```

1. Run Terraform

2. Terraform will output `github_actions_role_arn`.  Copy that arn into Github secrets with key `AWS_GITHUB_ACTIONS_ROLE_ARN`.

3. Run the workflow manually from the console.