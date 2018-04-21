# Salesforce
House of the new Sales System based on Salesforce!

# Scratch Org Creation:
1. Install node from from URL: https://nodejs.org/en/download/ (Windows installer 64bit)
2. run cmd--> cd <ProjectFolder>
3. run cmd--> npm run localhost
4. Go to following URL --> http://127.0.0.1:8080 in browser.
5. Enter Alias name and local project name --> Enter
6. Don't reload the page till you see the success message.


# Manual Steps
1. Login to Scratch org using the following command: “sfdx force:auth:web:login –r [Instance URL] –a [OrgAlias]”
2. Enable Setup->State & Country picklists(Step 2 & 3)
3. Enable Lead history tracking on org(Lead object-> Set History tracking)
4. Enable Account history tracking on org(Account object-> Set History tracking)
5. Enable Setup -> Account Settings->Allow users to relate a contact to multiple accounts
6. Setup->Sharing Settings->Lead & Conga template(objects should be marked private)
7. Setup-> User Interface -> Enable Middle Names for Person Names
8. Setup->Notes Settings-> Enable Notes
9. Change existing profiles & do a pull
10. Discard changes(profile related) shown in VSC.
11. Enable Currency(Setup->Company Information->Enable Currency management)
12. Go to the SFDX project folder in command prompt
13. Execute the following command “sfdx force:source:push –u [Org Alias] -f”


