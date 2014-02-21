import requests
import json
import time

import BaseHTTPServer
from SimpleHTTPServer import SimpleHTTPRequestHandler
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from SocketServer import ThreadingMixIn
import SocketServer
import threading

import subprocess

import argparse
import sys
import __main__
from argparse import RawTextHelpFormatter

from datetime import datetime
import hashlib
import codecs
import traceback

import os.path

PK_TIMEOUT = 60
TALLY_TIMEOUT = 3600
CERT = '/srv/certs/selfsigned/cert.pem'
KEY = '/srv/certs/selfsigned/key-nopass.pem'
DATA_DIR = "data"

# configuration
localServer = 'agoravoting-eovm'
localPort = 8000
node = '/usr/bin/node'
tallyUrl = 'https://agoravoting-eovm:5000/public_api/tally'
tallyData = {
    # 'election_id': electionId,
    "callback_url": "http://" + localServer + ":" + str(localPort) + "/receive_tally",
    "extra": [],
    "votes_url": "http://" + localServer + ":" + str(localPort) + "/" + DATA_DIR + "/",
    "votes_hash": "sha512://"
}
startUrl = 'https://agoravoting-eovm:5000/public_api/election'
# FIXME grab this from authorities tarball
authoritiesData = [
        {
            "name": "Auth1",
            "orchestra_url": "https://agoravoting-eovm:5000/api/queues",
            "ssl_cert": """-----BEGIN CERTIFICATE-----
MIIGLzCCBBegAwIBAgIJAJT2kz17RqWyMA0GCSqGSIb3DQEBBQUAMIGtMQswCQYD
VQQGEwJFUzEPMA0GA1UECAwGTWFkcmlkMQ8wDQYDVQQHDAZNYWRyaWQxFDASBgNV
BAoMC0Fnb3Jhdm90aW5nMR0wGwYDVQQLDBRDb25ncmVzb1RyYW5zcGFyZW50ZTEZ
MBcGA1UEAwwQYWdvcmF2b3RpbmctZW92bTEsMCoGCSqGSIb3DQEJARYdaW5mb0Bj
b25ncmVzb3RyYW5zcGFyZW50ZS5jb20wHhcNMTQwMjIwMTM1MTE1WhcNMTUwMjIw
MTM1MTE1WjCBrTELMAkGA1UEBhMCRVMxDzANBgNVBAgMBk1hZHJpZDEPMA0GA1UE
BwwGTWFkcmlkMRQwEgYDVQQKDAtBZ29yYXZvdGluZzEdMBsGA1UECwwUQ29uZ3Jl
c29UcmFuc3BhcmVudGUxGTAXBgNVBAMMEGFnb3Jhdm90aW5nLWVvdm0xLDAqBgkq
hkiG9w0BCQEWHWluZm9AY29uZ3Jlc290cmFuc3BhcmVudGUuY29tMIICIjANBgkq
hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA3X6tmFAoxAInqMyxnBf9CCf9IKgDGieW
5LOl98GzBmZf8Fu+MoXIPbFt2ncW2sfgUOwKGX+QL8CNJeTnQEsrrUewHH8e0Vy2
OR4wlCDuhqYfyjWrubBfkmsgux2+aZzZqJCsmDe1r7kgub4UaIHAKVCJPSpiB7y3
G1cABfSklmsofuEP1uFry9f6XtfZfTkhK7Q8Qi7xP4ZOWr2mIsy4jTCTGMNzOynt
lEYqV2f47VqW2og1L+d6YXS/ZyrmQftL94/ojNXylJ2UpUJOWb7CMtbZX6jqCoMG
zkkgIWFokhD4joutF+DxD5M+RPy2EKsVOGfP5RElPr0YzO7FoHFp38xhKB26529d
pC/ApS+M8nSCWXm2vOaG0vxLvZfqI2HVx9D1ghIGR0arfQuVz3xu4wTsxZnDvaMv
MTwg1bcPkEcNLn8R31kS/PeV5ALwm3QsaatocKiJKlkzi5JfG28Kr6iS82pMB68W
rFMTueEebGDBkl3OQHEqZuxi0dIz3C21AfFhYaPHrEJInwZ3tPJ2xLtA8E2mB4X/
WsmNHkMBYu/5JnUSBBykDHL4JXRxrUzZ3Vq8Rc+HTGO8YBdJAp5wS8X6qMG0ETDO
R0p1aT4C8VMNUkZrSGBPZRTlEW2p63cTRtNhpbqU6oiTUTLbEXkovxt+jJzG1YOO
cBT53+OBMesCAwEAAaNQME4wHQYDVR0OBBYEFJPrB6WSh+jlFA+ZgS4/qQ81dVl1
MB8GA1UdIwQYMBaAFJPrB6WSh+jlFA+ZgS4/qQ81dVl1MAwGA1UdEwQFMAMBAf8w
DQYJKoZIhvcNAQEFBQADggIBAD0xwYkAQ4ViXbHcSYBIt1MGbRxEkqvIH0rsclZT
bYXRvpec2hj90W9bRqJcHIhVV6RsaxQ5UicUBOz6tETwCLsq+TKkQ9gf6Y9W+YLk
s4BfJDICzh5n6dH3mejfH5WIKoIQXGhw9QjvDNWFlwGcN1oWzP2R5uSfXbcJOG7q
J6OnvMGkH/ijqQMCQgdDR5s6RgOTFMZz570McSjbpWkzFnRushlJyoljp6d5tLQo
ObvLPoFfkH/H7LckbkpAMvKo4RFIlSd6E8s/m1GjG7gTh6exTh/AVgCDrICXorba
eUdxvlbO+40HVvd0N2wxtiZoIFe6qBTr+Ax0s/wrnRPlcq15hU/w+lu/sO7SRYvU
EWEqHuKFxcFl4lfwyTO9wcuMH6Sn1Hk7n9brfTEKWMRHNVlZ/7vpDbtW57d2cbRY
iPobH2ZPLTPCNxE83XRZ7duPb+1nXajt0VJDEE/2DZgQcMqEVcrD2Jfi3bK1jUdC
lYMtRXZ+ULtmewWseKWpxIhiVHKfeRxNkAq6MJnCDj+I2nk5ptfKYEBhXScr5PG5
RrAJUppW1+vdWUsmm1s1XIspdJQefRmleMQkkWuspjnSQjQyRvwuaZO0WOwWHSct
NpyDMJerO3aSrZ16i1byYc4P553eNn9sItrU00pD1CbJUuyNl6wPHqnIzAc0JyQg
1yJx
-----END CERTIFICATE-----"""
        },
        {
            "name": "Auth2",
            "orchestra_url": "https://agoravoting-eovm2:5000/api/queues",
            "ssl_cert": """-----BEGIN CERTIFICATE-----
MIIGMTCCBBmgAwIBAgIJAPqevruOc78lMA0GCSqGSIb3DQEBBQUAMIGuMQswCQYD
VQQGEwJFUzEPMA0GA1UECAwGTWFkcmlkMQ8wDQYDVQQHDAZNYWRyaWQxFDASBgNV
BAoMC0Fnb3Jhdm90aW5nMR0wGwYDVQQLDBRDb25ncmVzb1RyYW5zcGFyZW50ZTEa
MBgGA1UEAwwRYWdvcmF2b3RpbmctZW92bTIxLDAqBgkqhkiG9w0BCQEWHWluZm9A
Y29uZ3Jlc290cmFuc3BhcmVudGUuY29tMB4XDTE0MDIyMDEzNTcwOFoXDTE1MDIy
MDEzNTcwOFowga4xCzAJBgNVBAYTAkVTMQ8wDQYDVQQIDAZNYWRyaWQxDzANBgNV
BAcMBk1hZHJpZDEUMBIGA1UECgwLQWdvcmF2b3RpbmcxHTAbBgNVBAsMFENvbmdy
ZXNvVHJhbnNwYXJlbnRlMRowGAYDVQQDDBFhZ29yYXZvdGluZy1lb3ZtMjEsMCoG
CSqGSIb3DQEJARYdaW5mb0Bjb25ncmVzb3RyYW5zcGFyZW50ZS5jb20wggIiMA0G
CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCk3ydC7aRMHAAPjtyMzfpALsgu8XYf
rEV2slXJqfE3Tdb5T+PeTBm9VklFowNdwmXRljM7wfHgDPQL7jddhUZLdb819noi
Vt8H/IwcTfdB5IzXnYCkLKrse9Xcf+FnUcfwPE4L0mPcVLZkAC9JoSxy1Um7d/5W
XgRYWYHBlwTjJPjI8pmuGqRdsOJ8gnf+ouNcE843jmsOJDGLU2H68hgZwRy7biRO
nPqRUTVVzZ/bIYGeLPhwVTah4XpMD3n5xjVp6NxiYm/3XtrOKBiQED5dBoeFRYIU
2vtrH8U8D3Vi30BdK4Y5VKaqpABvWLqf9LhZEMLXH6WB2JfDmxPMu7ZhdZLqAbp+
3kYbYUiHRn83NCTheunWUiEC7u53Vn+vnG8t4cYb/cHr7pZmdbd8HQeAlsvbdhiQ
zr5fNuCumAD+I+NOaglKTNwEUdxPmSWp9G+o0dZ25W+MDF7sVvZ8JfU2FN3R4eiy
jTlc/Cy4DqfJUMqmH9vrCcWGFi3i1zp+YpVrO0eLgdX3V3RAvot0pmDe3pmf17mW
YeAPg+UCBZyZSy89WITU8Cq4+T8peALGoKZgF73EgSftgpvATgvnFOw4CRPeY6Cn
lD0hSQ1RHKH+HgsKCPo7Qid154/Ml0+zw9NegTMNz2H9Vq01g+ncTYL/zECdDs63
ZhbyLQO5dfTBTQIDAQABo1AwTjAdBgNVHQ4EFgQUllH8b+1seWi/K7B6nL3ZYEax
HlcwHwYDVR0jBBgwFoAUllH8b+1seWi/K7B6nL3ZYEaxHlcwDAYDVR0TBAUwAwEB
/zANBgkqhkiG9w0BAQUFAAOCAgEAEZGtlUHaP9zW3Se+Yoviy9r/NXWEvMXm32Jp
8kGFYg/HRIZrVnxk4gu+tdfPwxHzgmrVAJxj+Zz0eumWCD9AJVF+wfh2bAKJzXys
rLp0PDXlEzYco4j2MfS21JcFnUDyQxWNxmYokpQwnEn13xpsJPmZ/XIGIWR6Hwej
4y09GzqbQPYvx6tjge25gDfaKz3eKBjEb3qo4jk9iog/+a4SoIgPRp7GoOeRVZ7E
hZPJipeU6KQ/ToG7YzmzS/9gT6u7C4x0xVArX0PQCacLnLk54gGxx1ytF/dHHp/p
X1xc9w/kvoydKpZ2g6DlEMjc5cvVdN5/hYvv0XK7vmf+6bychyhqVpCw+S35adwW
QWOP6r6FUg67/3Y35VzMTgE6IRNa25KxQ6Eu4lRoa556534/N8kLJi5m7y82C88F
c25GK4ULSxxxGWE8K5G+9kAGwYny1E6oidzJefewG3vnoH1OaCjNXtqxuNx+Qhw9
XTcJRQtd42VpJrMME+uGYal4Es4H3qgqf4CwvAEZmYBKU9JTr99DQ/I525mxE9m9
C22hrixY/sFovjfmuBTbKNmjNgMOlLfjrF7/QlHaw5ca5C5LEhBpTge/DQXfZzgp
E2Lmr0u/4Bc1lrv8Kj4ZJz0yysMPNfrM2SxfC28l4Oxm7uGQ31pPUkP5j55dEksv
hcxIp9g=
-----END CERTIFICATE-----"""
        }
    ]

startData = {
    # "election_id": electionId,
    "is_recurring": False,
    "callback_url": "http://" + localServer + ":" + str(localPort) + "/key_done",
    "extra": [],
    "title": "Test election",
    "url": "https://example.com/election/url",
    "description": "election description",
    "questions_data": [{
        "question": "Who Should be President?",
        "tally_type": "ONE_CHOICE",
        # "answers": ["Alice", "Bob"],
        "answers": [
            {'a': 'ballot/answer',
            'details': '',
            'value': 'Alice'},
            {'a': 'ballot/answer',
            'details': '',
            'value': 'Bob'}
        ], 
        "max": 1, "min": 0
    }],
    "voting_start_date": "2013-12-06T18:17:14.457000",
    "voting_end_date": "2013-12-09T18:17:14.457000",
    "authorities": authoritiesData 
}

# code

# thread signalling
cv = threading.Condition()

class ThreadingHTTPServer(SocketServer.ThreadingMixIn, BaseHTTPServer.HTTPServer):
    pass

class RequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        print("> HTTP received " + self.path)
        if(self.path == "/exit"):            
            self.send_response(204)
            cv.acquire()
            cv.done = True
            cv.notify()
            cv.release()            
        else:
            SimpleHTTPRequestHandler.do_GET(self)

    def do_POST(self):        
        length = int(self.headers['Content-Length'])
        print("> HTTP received " + self.path + " (" + str(length) + ")")
        raw = self.rfile.read(length).decode('utf-8')        
        data = json.loads(raw)
        
        # print(data)
        self.send_response(200)
        cv.acquire()
        cv.done = True
        cv.data = data
        cv.notify()
        cv.release()

# misc\utils.py
BUF_SIZE = 10*1024
def hash_file(file_path):
    '''
    Returns the hexdigest of the hash of the contents of a file, given the file
    path.
    '''
    hash = hashlib.sha512()
    f = open(os.path.join(DATA_DIR, file_path), 'r')
    for chunk in f.read(BUF_SIZE):
        hash.update(chunk)
    f.close()
    return hash.hexdigest()

def writeVotes(votesData, fileName):
    # forms/election.py:save
    votes = []
    for vote in votesData:
        data = {
          "a": "encrypted-vote-v1",
          "proofs": [],
          "choices": [],
          "voter_username": 'foo',
          "issue_date": str(datetime.now()),
          "election_hash": {"a": "hash/sha256/value", "value": "foobar"},
          "election_uuid": 'vota14'
        }

        q_answer = vote['question0']
        data["proofs"].append(dict(
            commitment=q_answer['commitment'],
            response=q_answer['response'],
            challenge=q_answer['challenge']
        ))
        data["choices"].append(dict(
            alpha=q_answer['alpha'],
            beta=q_answer['beta']
        ))

        votes.append(data)

    # tasks/election.py:launch_encrypted_tally    
    with codecs.open(os.path.join(DATA_DIR, fileName), encoding='utf-8', mode='w+') as votes_file:
        for vote in votes:
            # votes_file.write(json.dumps(vote['data'], sort_keys=True) + "\n")
            votes_file.write(json.dumps(vote, sort_keys=True) + "\n")

    # hash = hash_file(fileName)

    # return hash

def startServer(port):
    # server = SocketServer.TCPServer(("",8000), RequestHandler)
    print("> Starting server on port " + str(port))
    server = ThreadingHTTPServer(('', port),RequestHandler)
    thread = threading.Thread(target = server.serve_forever)
    thread.daemon = True
    thread.start()

def startElection(electionId, url, data):
    data['election_id'] = electionId
    print("> Creating election " + electionId)
    cv.done = False
    r = requests.post(url, data=json.dumps(data), verify=False, cert=(CERT, KEY))
    print("> " + str(r))

def waitForPublicKey():
    start = time.time()
    cv.acquire()
    cv.wait(PK_TIMEOUT)   
    pk = ''
    if(cv.done):
        diff = time.time() - start
        try:
            pk = cv.data['session_data'][0]['pubkey']
            print("> Election created (" + str(diff) + " sec), public key is")
            print(pk)            
        except:
            print("* Could not retrieve public key " + str(cv.data))
            print traceback.print_exc()
    else:
        print("* Timeout waiting for public key")
    cv.release()
    
    return pk

def doTally(electionId, url, data, votesFile, hash):
    data['votes_url'] = data['votes_url'] + votesFile
    data['votes_hash'] = data['votes_hash'] + hash
    data['election_id'] = electionId
    # print("> Tally post with " + json.dumps(data))
    print("> Requesting tally..")
    cv.done = False
    r = requests.post(url, data=json.dumps(data), verify=False, cert=(CERT, KEY))
    print("> " + str(r))

def waitForTally():
    start = time.time()
    cv.acquire()
    cv.wait(TALLY_TIMEOUT)    
    ret = ''
    if(cv.done):
        diff = time.time() - start
        # print("> Received tally data (" + str(diff) + " sec) " + str(cv.data))
        print("> Received tally data (" + str(diff) + " sec)")
        if('tally_url' in cv.data['data']):
            ret = cv.data['data']            
    else:
        print("* Timeout waiting for tally")
    cv.release()

    return ret

def downloadTally(url, electionId):
    fileName = electionId + '.tar.gz' 
    print("> Downloading to " + fileName)
    with open(os.path.join(DATA_DIR, fileName), 'wb') as handle:
        request = requests.get(url, stream=True, verify=False, cert=(CERT, KEY))

        for block in request.iter_content(1024):
            if not block:
                break

            handle.write(block)






''' driving functions '''

def create(args):
    electionId = args.electionId
    startServer(localPort)
    startElection(electionId, startUrl, startData)
    publicKey = waitForPublicKey()
    pkFile = 'pk' + electionId

    if(len(publicKey) > 0):            
        print("> Saving pk to " + pkFile)
        with codecs.open(os.path.join(DATA_DIR, pkFile), encoding='utf-8', mode='w+') as votes_file:
            votes_file.write(json.dumps(publicKey))
    else:
        print("No public key, exiting..")
        exit(1)

    return pkFile

def encrypt(args):
    electionId = args.electionId
    pkFile = 'pk' + electionId    
    votesFile = args.vfile
    votesCount = args.vcount
    print("> Encrypting votes (" + votesFile + ", pk = " + pkFile + ", " + str(votesCount) + ")..")
    pkPath = os.path.join(DATA_DIR, pkFile)
    votesPath = os.path.join(DATA_DIR, votesFile)
    # if not present in data dir, use current directory
    if not (os.path.isfile(votesPath)):
        votesPath = votesFile
    if(os.path.isfile(pkPath)) and (os.path.isfile(votesPath)):
        output, error = subprocess.Popen([node, "encrypt.js", pkPath, votesPath, str(votesCount)], stdout = subprocess.PIPE).communicate()

        print("> Received Nodejs output (" + str(len(output)) + " chars)")
        parsed = json.loads(output)
        
        ctexts = 'ctexts' + electionId
        print("> Writing file to " + ctexts)
        writeVotes(parsed, ctexts)    
    else:
        print("No public key or votes file, exiting..")
        exit(1)

def tally(args):
    if(args.command[0] == "tally"):
        startServer(localPort)

    electionId = args.electionId    

    ctexts = 'ctexts' + electionId            
    # need hash
    hash = hash_file(ctexts)
    print("> Votes hash is " + hash)
    doTally(electionId, tallyUrl, tallyData, ctexts, hash)
    tallyResponse = waitForTally()

    if('tally_url' in tallyResponse):
        print("> Downloading tally from " + tallyResponse['tally_url'])
        downloadTally(tallyResponse['tally_url'], electionId)
    else:
        print("* Tally not found in http data")

def full(args):
    electionId = args.electionId    

    pkFile = create(args)
    
    if(os.path.isfile(os.path.join(DATA_DIR, pkFile))):
        encrypt(args)            
        tally(args)        
    else:
        print("No public key, exiting..")

def main(argv):
    if not (os.path.isdir(DATA_DIR)):
        print("> Creating data directory")
        os.makedirs(DATA_DIR)
    parser = argparse.ArgumentParser(description='EO testing script', formatter_class=RawTextHelpFormatter)
    parser.add_argument('command', nargs='+', default='full', help='''create: creates an election
encrypt <electionId>: encrypts votes 
tally <electionId>: launches tally
full: does the whole process''')
    parser.add_argument('--vfile', help='json file to read votes from', default = 'votes.json')
    parser.add_argument('--vcount', help='number of votes to generate (generates duplicates if more than in json file)', type=int, default = 0)
    args = parser.parse_args()
    command = args.command[0]
    if hasattr(__main__, command):
        if(command == 'create') or (command == 'full'):
            args.electionId = str(time.time()).replace(".", "")
        elif(len(args.command) == 2):
            args.electionId = args.command[1]            
        else:
            parser.print_help()
            exit(1)
        eval(command + "(args)")
    else:
        parser.print_help()

if __name__ == "__main__":
   main(sys.argv[1:])