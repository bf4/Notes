# GNU screen

basics

    screen -S new_session_name
    Ctrl+A+D #detach screen
    screen -ls # list sessions
    screen -r new_session_name # reattach to the detached session
    screen -x new_session_name # join an attached sessions
   
## Scrollback buffer

http://www.samsarin.com/blog/2007/03/11/gnu-screen-working-with-the-scrollback-buffer/

The number of scrollback lines can be configured in your $HOME/.screenrc file, by adding the following line:

    defscrollback 5000

This sets the scrollback to 5000 lines.

You can also override this default value when starting screen using the -h [num] option, where num is the number of scrollback lines.

    Hit C-a (Ctrl-A) : to go to the Screen command line and type scrollback num,

    Hit C-a i to display window information

ENTERING SCROLLBACK MODE AND NAVIGATING
To enter scrollback hit C-a [. A status line will indicate that you've entered copy mode. To exit scrollback mode, hit the escape button.

Navigating in scrollback mode will be pretty familiar to VI users. Here are some of the most common navigation keys (taken from the screen manpage):

    h -    Move the cursor left by one character
    j -    Move the cursor down by one line
    k -    Move the cursor up by one line
    l -    Move the cursor right by one character
    0 -    Move to the beginning of the current line
    $ -    Move to the end of the current line.
    G -    Moves to the specified line
        (defaults to the end of the buffer).
    C-u -  Scrolls a half page up.
    C-b -  Scrolls a full page up.
    C-d -  Scrolls a half page down.
    C-f -  Scrolls the full page down.

in scrollback mode,To copy text, move the cursor to the start of the text you want to copy, hit spacebar, move the cursor to the end of the text you want to copy (Screen will highlight the text to be copied as you move), and again hit spacebar. Screen will indicate the number of characters copied into the copy buffer.

To paste text, simply hit C-a ].

copying to the mac osx clipboard, Open $HOME/.screenrc and add the following line:

    bind b eval "writebuf" "exec sh -c 'pbcopy < /tmp/screen-exchange'"

http://www.saltycrane.com/blog/2008/01/how-to-scroll-in-gnu-screen/

    C-a S splits into two regions
    C-a tab switches input focus to the next region
    C-a X kills the current region
    C-a :resize numlines resizes the current region to numlines lines.

cheatsheet: http://arundelo.livejournal.com/390.html

http://superuser.com/questions/138748/how-to-scroll-up-and-look-at-data-in-gnu-screen

Add the following to your ~/.screenrc:

    termcapinfo xterm ti@:te@
    termcapinfo xterm-color ti@:te@
    
This will let you use the Terminal.app scrollbar instead of relying on screen's scrollback buffer.

http://linux.derkeiler.com/Mailing-Lists/Debian/2006-09/msg02969.html

When you are running your terminal sessions under gnu/screen and you
suddenly realize that you need to take a screen dump on the fly, all you
need to do is:

    issue the gnu/screen escape keyboard action (Ctrl-A by default) 
    :hardcopy -h dumpfile

The -h flag causes gnu/screen to write the contents of the current
display as well as the contents of the scrollback buffer to the
specified file.