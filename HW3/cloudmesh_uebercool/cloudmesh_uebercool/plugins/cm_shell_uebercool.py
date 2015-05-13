from __future__ import print_function
import os
from cmd3.console import Console
from cmd3.shell import command

from cloudmesh_uebercool.command_uebercool import command_uebercool


class cm_shell_uebercool:

    def activate_cm_shell_uebercool(self):
        self.register_command_topic('mycommands', 'uebercool')

    @command
    def do_uebercool(self, args, arguments):
        """
        ::

          Usage:
              uebercool NAME

          tests via ping if the host ith the give NAME is reachable

          Arguments:

            NAME      Name of the machine to test

          Options:

             -v       verbose mode

        """
        # pprint(arguments)

        if arguments["NAME"] is None:
            Console.error("Please specify a host name")
        else:
            host = arguments["NAME"]
            Console.info("trying to reach {0}".format(host))
            status = command_uebercool.status(host)
            if status:
                Console.info("machine " + host + " has been found. ok.")
            else:
                Console.error("machine " + host + " not reachable. error.")
        pass

if __name__ == '__main__':
    command = cm_shell_uebercool()
    command.do_uebercool("iu.edu")
    command.do_uebercool("iu.edu-wrong")
