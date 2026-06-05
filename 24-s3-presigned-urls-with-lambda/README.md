

```
 aws lambda invoke \
 --function-name example-function \
 --cli-binary-format raw-in-base64-out \
 --payload file://lambda_input.json \
 lambda_output.json
```