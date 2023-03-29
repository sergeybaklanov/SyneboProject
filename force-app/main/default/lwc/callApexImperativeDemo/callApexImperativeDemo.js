import { LightningElement, api, wire } from 'lwc';
import obtainRelatedContacts from '@salesforce/apex/AccountController.getRelatedContacts';

export default class CallApexImperative extends LightningElement {
    @api recordId;
    @api title;

    handleButtonClick() {

        obtainRelatedContacts({ //imperative Apex call
            accountId: this.recordId
        })
            .then(contacts => {
                console.log(JSON.stringify(contacts));
                //code to execute if related contacts are returned successfully
            })
            .catch(error => {
                //code to execute if related contacts are not returned successfully
                console.log(JSON.stringify(error));
            });
    }
}