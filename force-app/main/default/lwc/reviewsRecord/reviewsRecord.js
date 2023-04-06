import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import pullReviews from '@salesforce/apex/ReviewsController.pullReviews';

export default class ReviewsRecord extends LightningElement {
    @api recordId;
     isButtonDisable = false;

    @api async invoke() {
        if(!this.isButtonDisable){
            this.isButtonDisable=true;
            console.log("Hi, I'm an action.");
        try{
        const result = await pullReviews({movieRecordId: this.recordId});
          
        this.showSuccessMessage();
        } catch(error){
          console.log(error);
          this.showErrorMessage(error); } 
      setTimeout(()=>{ this.isButtonDisable =false;},10000);
       
         } else{
            console.log('Button disable');
        return;  
    }
    
  }

showSuccessMessage() {
    const evt = new ShowToastEvent({
        title: 'Success',
        message: 'Reviews records were updated.',
        variant: 'success',
    });
    this.dispatchEvent(evt);
}

showErrorMessage(error) {
    const evt = new ShowToastEvent({
        title: 'Error',
        message: 'An error has occurred:' + error,
        variant: 'error',
    });
    this.dispatchEvent(evt);
}

}

