# Flyk: Video Sharing Application
Flyk is a video sharing app comprised of an iOS application and a server built on Node.js. This project taught me many valuable lessons about software development on large projects and also expanded my knowledge about transcoding videos and serving large files over the network.
## Video Demonstration
#### Coming very soon!!
## iOS Application
- Written entirely using Swift.
- Utilized the following apple frameworks and APIs:
UIKit, CoreData, AVFoundation, Foundation.
- The app has the functionality for users to record, edit, and upload videos. As well as to follow other users and view, comment on, and share their posts.
- Comprised of approximately 10k lines of code.



## Server
- The repository for the server can be viewed [here](https://github.com/EdwardChapman/Flyk_Backend).
- Express.js is the framework for the server.
- PostgreSQL was chosen as the database for the project.
$~~~~~~~~~$
- Application Server:
    - Used express-validator to help with the sanitization and validation of user input. 
    - Used bcrypt to hash passwords when a user creates an account.

- Upload Server:
    - Used a queue structure to accept user uploads and queue them to be transcoded.
    - FFMPEG was the CLI chosen to transcode the video.
    - Implemented a custom Multer storage to allow Google Cloud Storage to be used as the upload location for incoming files prior to being transcoded.
    This enabled the use of smaller VMs with no disk and small memory sizes.
    - Google Cloud Storage was used to store videos after transcoding. The use of Cloud Storage greatly reduced the latency of serving files and allowed for signed urls to be used, improving the ability to limit access to files. 


## Conclusion
I am very proud of this project as I was able to create an application with a real use-case from inception to completion in 2 months. The project was designed with scaling in mind at every step and I believe that it would have succeeded at handing a fairly large user load. I look forward to using the skills I have learned while building Flyk on future projects.


