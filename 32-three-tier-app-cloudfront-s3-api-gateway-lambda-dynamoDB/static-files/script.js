async function fetchUserData() {
    const user_id = document.getElementById('user_id').value;
    if (!user_id) {
        alert('Please enter a User ID');
        return;
    }

    try {
        const response = await fetch(`<custom_domain>/users?user_id=${user_id}`);
        const data = await response.json();
        const userDetails = document.getElementById('userDetails');
        
        if (response.ok) {
            userDetails.innerHTML = `<pre>${JSON.stringify(data, null, 2)}</pre>`;
        } else {
            userDetails.innerHTML = `<p>${data.message}</p>`;
        }
    } catch (error) {
        console.error('Failed to fetch user data:', error);
    }
}