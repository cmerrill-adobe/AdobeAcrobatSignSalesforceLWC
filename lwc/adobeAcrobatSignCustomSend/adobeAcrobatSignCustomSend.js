import { LightningElement, api } from 'lwc';
import APP_ICON from '@salesforce/resourceUrl/echosign_dev1__AdobeSign_AppIcon';
import templates from '@salesforce/apex/adobeAcrobatSignCustomSend.templates';
import agreements from '@salesforce/apex/adobeAcrobatSignCustomSend.agreements';
import createAgreement from '@salesforce/apex/adobeAcrobatSignCustomSend.createAgreement';

export default class AdobeSign_lwc extends LightningElement {
    @api recordId;
    appIcon = APP_ICON;
    templates = [];
    templateCount = 0;
    agreements = [];
    agreementCount = 0;
    loading = false;
    NoTemplates = true;

    connectedCallback() {
        this.getTemplates();
        this.getAgreements();
    }

    getTemplates() {
        this.loading = true;
        templates({ recordId: this.recordId })
            .then(result => {
                this.templates = result;
                this.templateCount = result.length;
                this.loading = false;
            })
            .catch(error => {
                console.error(error);
                this.isLoading = false;
            });
    }

    getAgreements() {
        this.loading = true;
        agreements({ recordId: this.recordId })
            .then(result => {
                this.agreements = result.map(agreement => {
                    const mappedAgreement = {
                        ...agreement,
                        agreementLink: '/lightning/r/echosign_dev1__SIGN_Agreement__c/' + agreement.Id + '/view/',
                        recipientContactLink: '/lightning/r/Contact/' + agreement.echosign_dev1__Recipient__r.Id + '/view',
                        isSigned: agreement.echosign_dev1__StatusVisible__c === 'Signed',
                        sentDate: agreement.echosign_dev1__DateSent__c ? new Date(agreement.echosign_dev1__DateSent__c).toLocaleString() : null,
                        signedDate: agreement.echosign_dev1__DateSigned__c ? new Date(agreement.echosign_dev1__DateSigned__c).toLocaleString() : null,
                    };

                    if (agreement.echosign_dev1__Account__r) {
                        mappedAgreement.relatedAccountLink = '/lightning/r/Account/' + agreement.echosign_dev1__Account__r.Id + '/view';
                    }
                    return mappedAgreement;
                });

                this.agreementCount = result.length;
                this.loading = false;
            });
    }

    handleSelect(event) {
        this.loading = true;
        let templateId = event.detail.value;
        let recordId = this.recordId;
        createAgreement({ templateId: templateId, recordId: recordId })
            .then(result => {
                console.log('Agreement created: ' + result);
                window.location.href = '/' + result;
            })
            .catch(error => {
                console.error(error);
            });
    }
}
