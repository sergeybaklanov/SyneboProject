import { LightningElement, api } from 'lwc';
import pullReviews from '@salesforce/apex/ReviewsController.pullReviews';

export default class ReviewsRecord extends LightningElement {
    @api recordId;

    @api async invoke() {
        console.log("Hi, I'm an action.");
            try{
        const result = await pullReviews({movieRecordId: this.recordId});
        } catch(error){
          console.log(error);
      }   
  }
}