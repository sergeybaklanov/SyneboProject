import { LightningElement, api } from 'lwc';

export default class ChildComponent extends LightningElement {
@api message="start message in child component";

@api 
changeName(value){
    this.message=value;
}

childHandleEvent(){
    const event = new CustomEvent('btnclick', {
        detail: { 
            key: '545465sdfsdf',
            value : 'Message in value child'
         }
    });
    this.dispatchEvent(event);
}


}