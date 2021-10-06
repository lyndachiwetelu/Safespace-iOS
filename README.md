### About this Project:
Safespace is an app I am building.

### What is the app about?
Online therapy. 
Find therapists and book sessions with them. Have your sessions online via chat, voice or video call

### Major Technologies used:
- [WebRTC](https://webrtc.github.io/webrtc-org/native-code/ios/)
- [Socket.IO Swift Client](https://github.com/socketio/socket.io-client-swift)
- [PeerJS](https://peerjs.com/) ( On the server side for signaling)
- Swift
- See [Podfile](https://github.com/lyndachiwetelu/Safespace-iOS/blob/main/Podfile)

### How to run:
[Upcoming Info]

### References: 
[Stasel WebRTC Demo App](https://github.com/stasel/WebRTC-iOS/tree/main/WebRTC-Demo-App)

### Visual demo: (delays a little)
![Safespace iOS App](https://user-images.githubusercontent.com/5268429/136293478-caf2ce4f-62b4-4ef8-b261-446047776d14.gif)


### Titbits: 
This was my first attempt at using WebRTC on iOS. For perspective I also recently used it for the first time from a browser in the [web version of this app](https://github.com/lyndachiwetelu/safespace-frontend), via [peerjs](https://peerjs.com/) - which is a library that helps keep things simple for peer to peer connection and text or audio or video exchange between connected peers.


Now, because I used peer library on the web [for signaling via my node.js server app](https://github.com/lyndachiwetelu/safespace-backend), in order to connect WebRTC peer x on my iOS application with peer y who is on the browser, I had to handle signaling and initial peer connection the peerjs way. Which was an interesting challenge.


Short story is I used the peerjs socket and formatted socket messages exactly like a peer client would. How do I know how a peer client would format messages? By studying the peer client source code in `node_modules` of the frontend web app linked above.


The main challenge of this app was implementing the WebRTC client used in my iOS app and handling streaming and so on. This is where [Stasel's iOS WebRTC demo](https://github.com/stasel/WebRTC-iOS/tree/main/WebRTC-Demo-App) came in quite handy. I basically followed what was done there to establish a semi working example and adjusted quite a lot of things to fit my peerjs type connection setup, and my app in general.


I also had to handle switching connections from say audio to video to text and vice versa. Which was interesting. Learned a lot more about release and retain cycles in iOS programming.
