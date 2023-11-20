import requests
import json
import optparse
import sys
from urllib3.exceptions import InsecureRequestWarning


if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.add_option('-u', '--user',action="store", help="Prisma Cloud Console user format user:password", dest="user", type="string")
    parser.add_option('-p', '--password',action="store", help="Prisma Cloud Console password", dest="password", type="string")
    parser.add_option('-c', '--console', action="store", dest="console", help="Prisma Cloud Console address. Format saas: path to console. selfhosted: address:8083 ", type="string")
    parser.add_option('-r', '--runtime', action="store", dest="runtime", help="Conatiner runtime (crio, docker, containerd )", type="string")
    parser.add_option('-o', '--orchestrator', action="store", dest="orchestrator", help="Orchestration type (Kubernetes, openshift, ecs,)", type="string")
    parser.add_option('-t', '--type', action="store", dest="console_type", help="Conosole deployment type values(saas,selfhosted)", type="string")
    options, arguments = parser.parse_args()

    args = sys.argv[1::2]
    prog = sys.argv[0]
    
    user = options.user
    password = options.password
    console = options.console
    runtime = options.runtime
    orchestrator = options.orchestrator
    console_type = options.console_type

    options = dict(vars(options))
    if len(args) < 6:
          for i in options:
                if options[i] is None:
                      print("Error the option %s is mandatory" %i)
                      print("   Use %s  -h or --help to see the arguments" % prog)
                      sys.exit(1)

    json_user = {
        'username': '{}'.format(user),
        'password': '{}'.format(password)
    }
   
    if console_type == "saas":
          consoleaddr = console.split("/")[0]
    else:
          consoleaddr = console.split(":")[0]

    payload = json.dumps({
        "consoleAddr": "{}".format(consoleaddr),
        "namespace": "twistlock",
        "orchestration": "{}".format(orchestrator),
        "selinux": False,
        "containerRuntime": "{}".format(runtime),
        "privileged": False,
        "serviceAccounts": True,
        "istio": False,
        "collectPodLabels": False,
        "proxy": None,
        "taskName": None,
        "gkeAutopilot": False
      })
    
    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    } 

    requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
    r = requests.post('https://{}/api/v1/authenticate'.format(console), headers=headers, json=json_user, verify=False)
  
    json_response = r.json()
    auth = json_response["token"]

    headers['Authorization'] = 'Bearer' + " " + auth

    url = "https://{}/api/v1/defenders/daemonset.yaml".format(console)
 
    requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
    response = requests.request("POST", url, headers=headers, data=payload, verify=False)
    
    with open("daemonset.yaml", "w") as f:
       f.write(response.text)


