# pubkeypub

Support easier publishing of public keys to remote hosts for passwordless login etc.

## Installing

Copy the script to your path, e.g. $HOME/bin or /usr/local/bin.

## Usage:

    fthiele@bishkek:~/dev/git/pubkeypub/bin$ ./publish_key.sh

    Please provide a remote host to connect to.

    ########################
    # public key publisher #
    ########################

    Usage: ./publish_key.sh -h REMOTE_HOST [ -u REMOTE_USERNAME ] [ -p PATH/TO/PUBLIC_KEY ] [ -d ]

    Connects with to REMOTE_HOST using REMOTE_USERNAME and publishes the given
    PUBLIC_KEY into the .ssh/authorized_keys of REMOTE_USERNAME home. If no
    REMOTE_USERNAME was given, current USER is assumed also as remote name.
    If the PATH/TO/PUBLIC_KEY is omitted, the USER/.ssh/id_rsa.pub is assumed
    for the authorization process. Append a -d for performing a dry-run.

    fthiele@bishkek:~/dev/git/pubkeypub/bin$

## License Notice

Copyright (C) 2015 Fred Thiele <ferdy_news@gmx.de>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
