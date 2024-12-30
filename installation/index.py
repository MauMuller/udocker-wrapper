import yaml
import os
import functools
import subprocess
import time
import sys
import urllib.request

from classes.Formatters import Formatters

def executePython (values):
    for command in values or []:
        result = exec(command)

def executeShell (values):
    for command in values or []:
        output = subprocess.run(
                command, 
                capture_output=True, 
                shell=True, 
                text=True
        )

        if output.stderr:
            print(f"\n{output.stderr}")
            exit()

        if output.stdout.replace("\n", "").strip():
            print(f"\n{output.stdout}")
try:
    f = Formatters()
    path = os.path.realpath(os.path.dirname(__file__))
    
    with open(f"{path}/config.yaml") as yamlFile:
        result = yaml.safe_load(yamlFile)
        steps = result['steps'] or []
        start = result['start']
        end = result['end']

    executeShell(start.get('shell-commands'))

    messages = "\n".join(start.get('messages') or [])
    print(f"\n{f.BOLD}{f.OKGREEN}{messages}{f.ENDC}")
    
    questions = {}

    for step in steps:
        optionsList = step['options'].get('list') or []
        dependsOn = step['options'].get('dependsOn')

        keyStep = step.get('key')
        question = step.get('question')
        observation = step.get('observation')

        keysAndValuesOptions = list(enumerate(optionsList))
        possibleOptions = list(map(lambda item: str(item[0] + 1), keysAndValuesOptions))

        stopLoop = False

        while not stopLoop:
            print(f"\n- {f.BOLD}{question}{f.ENDC}")
            print(f"{f.TABS}{f.ITALIC}{f.OKCYAN}{observation}{f.ENDC}\n")

            for index, option in keysAndValuesOptions:
                key = index + 1
                name = option.get('name')

                print(f"{f.TABS}{key}° {f.UNDERLINE}{name}{f.ENDC}")

            default = '1'
            sectionQuestion = f"\n{f.TABS}> {f.ITALIC}(default: {default}){f.ENDC} "
            stdin = input(sectionQuestion)
            value = stdin if stdin.isnumeric() and int(stdin) > 0 else default

            if value not in possibleOptions:
                clearShell = {"shell-commands": ["clear"] }
                executeDinamicOsAndPythonModules(clearShell)

                print(f"\n{f.BOLD}{f.OKGREEN}{messages}{f.ENDC}")
                print(f"\nInvalid input, please digit a number between list above.")
                continue
            
            stopLoop = True

        integer = int(value) - 1
        option = optionsList[integer] or {}
        
        shellCommands = []
        pythonCommands = []

        if dependsOn:
            typeSelected = questions[dependsOn]
            valuesScripts = option.get('values') or []

            for value in valuesScripts:
                if value.get('key') != typeSelected:
                    continue

                shellCommands = value.get('shell-commands') or []
                pythonCommands = value.get('python-commands') or []
        else:
            shellCommands = option.get('shell-commands') or []
            pythonCommands = option.get('python-commands') or []

        questions[keyStep] = option.get('key')
        
        executePython(pythonCommands)
        executeShell(shellCommands)

    messages = "\n".join(end['messages'])
    print(f"\n{f.BOLD}{messages}{f.ENDC}")

    executeShell(end.get('shell-commands'))
except KeyboardInterrupt:
    print('\nTerminal was interupted')
except ValueError as error:
    print(f"\nSomething was wrong, error: \n{error}")
except SyntaxError as error:
    line = error.lineno
    print(f"\nSyntax Error, line: {line}")
