# Concrete
Concrete is a minimalistic Continuous Integration server.

![concrete](http://dl.dropbox.com/u/1152970/concrete_screenshot_hi.png)

##Install guide

1) Run vagrant up or ./ec2-package.sh depending on your desired environment  
2) SSH to your VM or EC2 and run the following commands  

`sudo mkdir /RedBadger`  
`sudo chown ubuntu /RedBadger` (user is vagrant inside VM)  
`git clone git://github.com/redbadger/concrete.git`  
`sudo ln -s /RedBadger/concrete/bin/concrete /usr/bin/concrete`  

## Usage
    Usage: concrete [-hpv] path_to_git_repo

    Options:
      -h, --host     The hostname or ip of the host to bind to  [default: "0.0.0.0"]
      -p, --port     The port to listen on                      [default: 4567]
      --help         Show this message
      -v, --version  Show version