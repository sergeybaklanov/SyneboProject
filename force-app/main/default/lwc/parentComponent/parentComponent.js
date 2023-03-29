import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {
    //message="Some message inside Parent set";
    messageParent="";
    
    clickHandler(){
        this.message="message was changed in child component by using query locator ";
        this.template.querySelector('c-child-component').changeName(this.message);
    }

    eventHandlerParent(event){
        let key = event.detail.key;
        let value = event.detail.value;
        this.messageParent=key+''+value;
    }
}