


```
kubectl apply -f eks-test.yaml
```

Now, exec into the Nginx pod:
```
kubectl exec -i deployment/eks-test-nginx -- //bin/sh
```

and print the `index.html` file:
```
cat /usr/share/nginx/html/index.html
```

This should print all of the contents of `index.html` file if everything is working correctly.