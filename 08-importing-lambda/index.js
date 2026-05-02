console.log('Loading function');

export const handler = async (event, context) => {
    console.log('manually created lambda function but now managed by Terraform');
};