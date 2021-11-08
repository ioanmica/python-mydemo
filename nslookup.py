import subprocess
from django.db import connection

domain = input("Enter the Domain: ")
output = subprocess.check_output(f"nslookup {domain}", shell=True, encoding='UTF-8')
print(output)

smth = "this is proba 1"

def find_user(username):
    with connection.cursor() as cur:
        cur.execute(f"""select username from USERS where name = '%s'""" % username)
        output = cur.fetchone()
    return output
