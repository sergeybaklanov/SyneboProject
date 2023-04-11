import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CinemaNavTab extends NavigationMixin(LightningElement) {
    @api navigateNext(selectedMarkerValue) {
        if(selectedMarkerValue){
        console.log(selectedMarkerValue);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedMarkerValue,
                objectApiName: 'Cinema__c',
                actionName: 'view'
            }
        });
         }
         else{
            this.showErrorMessage();
         }
}
showErrorMessage() {
    const evt = new ShowToastEvent({
        title: 'Error',
        message: 'Please select Cinema first',
        variant: 'error',
    });
    this.dispatchEvent(evt);
}
}