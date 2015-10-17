[![Circle CI](https://circleci.com/gh/MLH/no-light/tree/master.svg?style=svg)](https://circleci.com/gh/MLH/no-light/tree/master)

This is a lightweight [Sinatra](http://sinatra-rb.com) app that we're using for our mini-event, No Light.

## How to use
Participants can visit any custom URL (i.e. `http://no-light.mlh.io/enter-any-hackathon-name-here`) with no prior configuration. They can then, within a designated amount of time, submit their code for the event and have it saved to a MongoDB instance.

Then, by appending `.zip` to the URL, it generates a ZIP file with all of the entries. This avoids the need of each participant needing to come up on stage to present their submissions, which makes the event more focused on writing code and having fun.