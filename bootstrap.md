# bootstrap

* [Google Chrome](http://google.com/chrome) [download](https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg)
* [alfred](http://www.alfredapp.com/), [download](http://rwc.cachefly.net/alfred_1.2_220.dmg)
* [homebrew](https://github.com/mxcl/homebrew)
* [gitx](http://frim.frim.nl/GitXStable.app.zip)
* [github for mac](https://github-central.s3.amazonaws.com/mac%2FGitHub%20for%20Mac%201.2.8.zip)
* xcode [snow leopard](http://adcdownload.apple.com/Developer_Tools/xcode_3.2.6_and_ios_sdk_4.3__final/xcode_3.2.6_and_ios_sdk_4.3.dmg), [lion command line](http://adcdownload.apple.com/Developer_Tools/command_line_tools_for_xcode__june_2012/command_line_tools_for_xcode_june_2012.dmg), [lion Xcode full](http://adcdownload.apple.com/Developer_Tools/xcode_4.3.3_for_lion/xcode_4.3.3_for_lion.dmg)
* [cdto project](http://code.google.com/p/cdto/), [download](http://cdto.googlecode.com/files/cdto_2.5.zip)

  *  brew install git
  *  brew install macvim
  *  brew install ack
  *  brew install wget

* [sequel pro](http://www.sequelpro.com/download/)
* [fluid app sso](http://fluidapp.com/)
* [caffeine](http://lightheadsw.com/caffeine/)
* rvm

  * <code>curl -L https://get.rvm.io | bash -s stable --ruby</code>
  * <code>rvm install 1.8.7-p72 -C --enable-pthread</code>
  * <code>rvm use 1.8.7-p72@global --default</code>


* install activestate active tcl to get require 'tk' to work, and then 'drx' (install graphviz)


* ssh key
  * <code>ssh-keygen -t rsa -C "username@example.com"</code> with a password
  * <code>pbcopy < ~/.ssh/id_rsa.pub</code>

* <code>openssl passwd -1</code>

* clone dotfiles, vimfiles

* [dropbox](https://www.dropbox.com/downloading?src=index)

* [iChat helper: Chax](http://www.ksuther.com/chax/ http://www.ksuther.com/chax/downloads/Chax.dmg)

* [tunnelblick (vpn)](http://code.google.com/p/tunnelblick), [download](  http://tunnelblick.googlecode.com/files/Tunnelblick_3.2.6.dmg)

## bash_profile
*  <code>alias ss='sync -av --exclude "CVS*" --exclude "*.kpf" --exclude ".DS_Store" --exclude ".git" --exclude ".gitignore" $HOME/workspace/ example@server:/var/folder/</code>

* add this to system pref > search domains
  * subdomain.site.com, localtld

## tmux

* tmux per http://rhnh.net/2011/08/20/vim-and-tmux-on-osx and http://joshuadavey.com/post/15619414829/faster-tdd-feedback-with-tmux-tslime-vim-and
  * <code>easy_install pip</code>
  * <code>brew install mercurial</code>
  * <code>brew install https://raw.github.com/Homebrew/homebrew-dupes/master/vim.rb</code>
  * <code>brew install tmux</code>
  
* .bash_profile
 * <code>alias tmux="TERM=screen-256color-bce tmux"</code>
* .tmux.conf
  * <code>set -g default-terminal "screen-256color"</code>
  * <code>set -g mode-mouse on</code>
  
## Node, npm

    brew install nodejs
    curl http://npmjs.org/install.sh | sh
   
## Redis

    brew install redis
    
## Apps

### Chat app: Balloons.io

    git clone git://github.com/gravityonmars/Balloons.IO.git balloons
    cd balloons
    npm install