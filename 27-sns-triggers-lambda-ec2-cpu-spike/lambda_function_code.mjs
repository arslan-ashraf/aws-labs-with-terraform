export const handler = async (event) => {
    console.log(`
        This lambda function is intended to run in response to 
        EC2 instance CPU utilization being above the desired 
        threshold of 50%.
    `)
}