#!/usr/bin/python

import sys
import os
from subprocess import call


log_enabled = False


class PartialProgramAnalyser:
    """ Partial program analyser """

    def __init__(self, in_file_name):
        # Accept absolute or relative paths; normalize to absolute paths so
        # downstream operations (chdir, writing outputs) behave correctly.
        self.in_file_name = os.path.abspath(in_file_name)
        (base, ext) = os.path.splitext(os.path.basename(self.in_file_name))
        in_dir = os.path.dirname(self.in_file_name) or "."
        # Generated and fixed files live next to the input file so includes
        # remain local and the code can reference them by basename.
        self.gen_file_name = os.path.join(in_dir, base + "_gen.h")
        self.fixed_file_name = os.path.join(in_dir, base + "_fixed.c")

    @staticmethod
    def write_log(msg):
        if log_enabled:
            print "[Reconstructor] %s" % msg

    def gen_constraints(self):
        """ Invoke our constraint generator """
        self.write_log("Generating constraints")

        # If there's an old constraints file in the current working directory,
        # delete it. Keep a.cstr local to the working directory where the
        # script is executed to mirror existing behaviour.
        if os.path.isfile("a.cstr"):
            os.remove("a.cstr")

        # Call the constraint generator with the absolute input path.
        call(["./psychecgen", "%s" % self.in_file_name])

    def solve_constraints(self):
        """ Invoke our constraint solver """
        self.write_log("Solving constraints")

        # The solver expects to run from the "solver" subdirectory; change
        # there but pass absolute paths for inputs/outputs to avoid issues
        # when the input file is absolute.
        cwd = os.getcwd()
        os.chdir("solver")
        try:
            call(["stack", "exec", "psychecsolver-exe", "--",
                  "-i", os.path.join(cwd, "a.cstr"),
                  "-o", self.gen_file_name])
        finally:
            os.chdir(cwd)
        os.chdir("..")

    def fix_program(self):
        """ Create a new source that includes the solved stuff"""
        self.write_log("Creating new complete source")

        content = "/* Reconstructed from %s */\n" % self.in_file_name
        local_gen_file = os.path.basename(self.gen_file_name)
        content += '#include "%s"\n' % local_gen_file

        with open(self.in_file_name, "r") as f:
            content += f.read()

        # Write the fixed file beside the original input.
        with open(self.fixed_file_name, "w") as f:
            f.write(content)

    def analyse(self):
        self.gen_constraints()
        self.solve_constraints()
        self.fix_program()


if __name__ == "__main__":
    if (len(sys.argv)) != 2:
        print("Usage: ./reconstruct.py <relative-or-absolute-path-to-file.c>")
        sys.exit(1)

    analyser = PartialProgramAnalyser(sys.argv[1])
    analyser.analyse()
