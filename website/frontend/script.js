const API_URL = 'http://localhost:5001';

// Update slider values in real-time
document.querySelectorAll('input[type="range"]').forEach(slider => {
    const valueDisplay = document.getElementById(`${slider.id}_value`);
    slider.addEventListener('input', (e) => {
        valueDisplay.textContent = e.target.value;
    });
});

document.getElementById('predictionForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    try {
        console.log('Sending prediction request...'); // Debug log
        
        // Collect numeric values
        const numericInputs = {
            'median_forever': parseFloat(document.getElementById('median_forever').value) * 60,
            'r_price': parseFloat(document.getElementById('r_price').value),
            'Achievements': parseInt(document.getElementById('Achievements').value),
            'Language_N': parseInt(document.getElementById('Language_N').value),
            'Platform_N': parseInt(document.getElementById('Platform_N').value)
        };

        // Collect binary values (checkboxes)
        const binaryFeatures = [
            'Steam_Trading_Cards', 'Adventure', 'Action', 'Simulation', 
            'Casual', 'Indie', 'Steam_Cloud', 'Strategy', 
            'Partial_Controller_Support', 'RPG', 'Full_controller_support',
            'Free_To_Play', 'Steam_Achievements', 'discount', 
            'Steam_Leaderboards', 'Family_Sharing', 'Multi_player',
            'Early_Access', 'Stats', 'Remote_Play_on_TV', 'Co_op',
            'Sports', 'Steam_Workshop', 'Racing', 'Includes_level_editor'
        ];

        const binaryInputs = {};
        binaryFeatures.forEach(feature => {
            binaryInputs[feature.replace(/_/g, '.')] = 
                document.getElementById(feature).checked ? 1 : 0;
        });

        // Combine all inputs
        const formData = {
            ...numericInputs,
            ...binaryInputs
        };
        
        console.log('Request data:', formData); // Debug log
        
        const response = await fetch(`${API_URL}/predict`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(formData)
        });
        
        console.log('Response received:', response.status); // Debug log
        
        const result = await response.json();
        console.log('Response data:', result); // Debug log
        
        if (result.success) {
            document.getElementById('result').classList.remove('hidden');
            document.getElementById('predictionValue').textContent = 
                `Predicted number of owners: ${result.prediction} Players`;
        } else {
            alert('Error from server: ' + result.error);
        }
    } catch (error) {
        console.error('Error details:', error); // Debug log
        alert('Error connecting to the server. Check the console for details.');
    }
}); 