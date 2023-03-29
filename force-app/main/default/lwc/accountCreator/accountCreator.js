import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { customLabels } from './labels.js';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';


export default class AccountCreator extends LightningElement {

    // Option 1 to use @track
    @track label = customLabels;
    
    // Option 2 to use ge method
    /*get customLabels() {
        return customLabels;
    }*/

    objectApiName = ACCOUNT_OBJECT;
    fields = [NAME_FIELD, REVENUE_FIELD, INDUSTRY_FIELD];
    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: this.label.Account_created,
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }
}