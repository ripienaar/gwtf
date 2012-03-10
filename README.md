What?
=====

Go With The Flow is a Unix CLI centeric todo/task tracker.

Each todo item has a short description, a optional long description,
a status and a work log.

It supports different projects with unique lists of tasks and can track
time worked per task either through specifically supplying time worked
or via sub-shells.

gwtf is written using the excellent gli gem so it behaves a lot like
the git command line.

Tasks are stored in simple JSON files and each time you save or edit a
task a backup of the previous state is made.  There is a simple Ruby
API for interacting with the tasks list in your own code.

Basic Usage?
============

By default tasks are written to ~/.gwtf.d/ directory, sub directories
per project exist under this directory.

I alias gwtf to the _t_ command using my shell alias facilities.

Adding a task
-------------

    % gwtf new this is a test task
    Created a new project default in /home/rip/.gwtf.d/default
    Item 0 saved

You can pass an optional _--edit_ or _-e_ flag to the new command that
will start your editor configured using EDITOR to edit the long form
description of a task

Logging work for a task
-----------------------

Each task has a work log that you can write to:

    % gwtf log 0 "Create a README file" -m 20
    Logged 'Create a README file' against item 0 for 20 minutes 0 seconds

Viewing a task
--------------

    % gwtf show 0
             ID: 0
        Subject: this is a test task
         Status: open
    Time Worked: 20 minutes 0 seconds
        Created: 03/10/12 21:23

    Work Log:
                 03/10/12 21:25 Create a README file

Completing a task
-----------------

    % gwtf done 0
    Marked item 0 as done

List of tasks
-------------

By default completed tasks are not shown:

    % gwtf list
        1    this is another test task to demonstrate

    Items: 1 / 2

But you can list all tasks:

    % gwtf ls -a
        0 C  this is a test task
        1    this is another test task to demonstrate

    Items: 1 / 2

Logging work done interactively?
--------------------------------

If you're working on some code you can track the time spent working
on it using gwtf:

    % gwtf new add a readme file
    Item 3 saved

    % gwtf shell 3
    Starting work on item 3, exit to record the action and time

This shell will have GWTF_ITEM, GWTF_PROJECT and GWTF_SUBJECT enviroment
variables set for use in your prompt or shell script.

Now you can work in this shell and once you're done simply exit it:

    % exit
    Optional description for work log: First stab at writing a readme file
    Recorded 91.6566 seconds of work against item 3

Your log will be visible in the show command along with a total work time
for the task:

             ID: 3
        Subject: add a readme file
         Status: open
    Time Worked: 1 minutes 32 seconds
        Created: 03/10/12 21:41

    Work Log:
                 03/10/12 21:43 First stab at writing a readme file (1 minutes 32 seconds)

Projects?
=========

There is a very simplistic project model that simply creates a new
set of tasks in a different sub-directory off the top directory.

    % gwtf --project=acme new this is a different project
    Created a new project acme in /home/rip/.gwtf.d/acme
    Item 2 saved

Note that item numbers a unique for the entire installation to avoid
confusion due to overlapping item numbers.

Default Project and Data Dir?
=============================

You can adjust the default data dir and project which would then be saved
into the config file - _~/.gwtf_:

    % gwtf --help
    Global Options:
        --data, -d data_dir   - Path to storage directory (default: /home/rip/.gwtf.d)
        --help                - Show this message
        --project, -p project - Active project (default: default)

Now change the defaults:

    % gwtf --data=/tmp/gwtf -p acme initconfig
    Created a new project acme in /tmp/gwtf/acme

And confirm the change is active:

    % gwtf --help
    Global Options:
        --data, -d data_dir   - Path to storage directory (default: /tmp/gwtf)
        --help                - Show this message
        --project, -p project - Active project (default: acme)

You can reset to factory defaults by just rmoving the _~/.gwtf_ file or by changing
the defaults again.

Contact?
========

R.I.Pienaar / rip@devco.net / @ripienaar
