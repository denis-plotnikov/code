import gdb
class ListmPrefixCommand (gdb.Command):
  "Prefix command for saving things."

  def __init__ (self):
    super (ListmPrefixCommand, self).__init__ ("listm",
                         gdb.COMMAND_SUPPORT,
                         gdb.COMPLETE_NONE, True)

  def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)
        if len(argv) > 1:
          print "args error"
          return
        trackreq = gdb.parse_and_eval(argv[0]).cast(gdb.lookup_type('BdrvTrackedRequest').pointer())
        tail = gdb.parse_and_eval("*(void**)%s"%trackreq['list']['le_prev'])
        print tail
        nextp = trackreq['list']['le_next']
        print nextp
        #return
        i = 0
        os.system("rm /tmp/superlog.txt")
        gdb.execute("set logging file /tmp/superlog.txt")
        gdb.execute("set logging on")
        while nextp != 0:
          print "qemu coroutine %s"%trackreq['co']
          gdb.execute("qemu coroutine %s"%trackreq['co'])
          trackreq = nextp.cast(gdb.lookup_type('BdrvTrackedRequest').pointer())
          nextp = trackreq['list']['le_next']
          i+=1
        print i
        gdb.execute("set logging off")
        print gdb.execute("bt")

ListmPrefixCommand()

