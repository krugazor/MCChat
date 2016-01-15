# MCChat
Example code for Multipeer Connectivity : a somewhat simple and stupid chat app (Mac &amp; iOS)

The talk I gave to Cocoaheads on the topic seemed popular, and the participants eager for some sample code. Here it is.

It is provided as is, there is no test, no memory checks and a *horrible* system to display messages. It could, however, supper text or image messages, and is a decent example of how to use the framework.

Be aware that it won't ask for confirmiation to connect to peers, and will likely find the first one it can find. This isn't the way you should do it in your code. See [Apple's documentation](https://developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MultipeerConnectivityFramework/) for more information, or feel free to hit me up.
