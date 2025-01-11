### macos bundle security entitlements

For it to work, it must be signed and given appropriate entitlements.

To list identifies with code signing capabilities execute:

```
$ security find-identity -v -p codesigning
````

To sign the binary:

````
$ codesign -s $token --entitlements entitlements.xml _build/default/oq.exe
```

Where token can be obtained from the output of the security command. With only an identity,
we can automate it with:

```
$ token=$(security find-identity -v -p codesigning | awk '{print $2}' | sed 1q )
$ codesign --deep -s $token --entitlements entitlements.xml -o runtime _build/default/oq.exe
```
