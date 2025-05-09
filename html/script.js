document.addEventListener('DOMContentLoaded', function() {
    // UI Element references
    const genderUI = document.getElementById('gender-ui');
    const maleBtn = document.getElementById('male-btn');
    const femaleBtn = document.getElementById('female-btn');
    const closeBtn = document.getElementById('close-btn');
    
    // UI Text elements
    const uiTitle = document.getElementById('ui-title');
    const uiSubtitle = document.getElementById('ui-subtitle');
    const maleLabel = document.getElementById('male-label');
    const femaleLabel = document.getElementById('female-label');
    const closeLabel = document.getElementById('close-label');
    
    // Track if buttons are currently disabled
    let buttonsDisabled = false;
    let config = null;
    let activeCard = null;
    
    // Add keyboard navigation
    function setupKeyboardNavigation() {
        const focusableElements = [maleBtn, femaleBtn, closeBtn];
        let currentFocus = -1;
        
        // Set tab indices for keyboard navigation
        focusableElements.forEach(el => {
            el.setAttribute('tabindex', '0');
            el.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    this.click();
                }
            });
        });
        
        // Handle arrow key navigation
        document.addEventListener('keydown', function(e) {
            if (!displayingUI) return;
            
            if (e.key === 'Tab') {
                e.preventDefault(); // Prevent default tab behavior
                
                if (e.shiftKey) {
                    // Shift+Tab pressed - move backwards
                    currentFocus = currentFocus <= 0 ? focusableElements.length - 1 : currentFocus - 1;
                } else {
                    // Tab pressed - move forwards
                    currentFocus = currentFocus >= focusableElements.length - 1 ? 0 : currentFocus + 1;
                }
                
                focusableElements[currentFocus].focus();
            } else if (e.key === 'ArrowLeft' || e.key === 'ArrowRight') {
                e.preventDefault();
                
                if (document.activeElement === maleBtn || document.activeElement === femaleBtn) {
                    if (e.key === 'ArrowLeft') {
                        maleBtn.focus();
                    } else {
                        femaleBtn.focus();
                    }
                }
            }
        });
    }
    
    // Initialize keyboard navigation
    let displayingUI = false;
    
    // Function to handle messages from the client script
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.type === 'toggleUI') {
            // Reset button state whenever UI is toggled
            disableButtons(false);
            buttonsDisabled = false;
            displayingUI = data.display;
            
            // Remove any previous selection
            maleBtn.classList.remove('active', 'selected');
            femaleBtn.classList.remove('active', 'selected');
            activeCard = null;
            
            if (data.config) {
                config = data.config;
                applyConfig(config);
            }
            
            // Show or hide the UI
            genderUI.style.display = data.display ? 'flex' : 'none';
            
            // Setup keyboard navigation when UI is shown
            if (data.display) {
                setTimeout(() => {
                    setupKeyboardNavigation();
                    // Focus the first interactive element
                    maleBtn.focus();
                }, 100);
            }
        }
    });
    
    // Apply configuration to UI elements
    function applyConfig(config) {
        if (!config || !config.UI) return;
        
        // Set texts
        if (config.UI.title) uiTitle.textContent = config.UI.title;
        if (config.UI.subtitle) uiSubtitle.textContent = config.UI.subtitle;
        if (config.UI.maleLabel) maleLabel.textContent = config.UI.maleLabel;
        if (config.UI.femaleLabel) femaleLabel.textContent = config.UI.femaleLabel;
        if (config.UI.closeButtonLabel) closeLabel.textContent = config.UI.closeButtonLabel;
        
        // Set colors if provided
        if (config.UI.backgroundColor) document.documentElement.style.setProperty('--bg-color', config.UI.backgroundColor);
        if (config.UI.accentColor) document.documentElement.style.setProperty('--primary-color', config.UI.accentColor);
        if (config.UI.secondaryColor) document.documentElement.style.setProperty('--secondary-color', config.UI.secondaryColor);
        
        // Set font if provided
        if (config.UI.font) {
            document.body.style.fontFamily = config.UI.font;
        }
    }
    
    // Male button click handler
    maleBtn.addEventListener('click', function() {
        if (buttonsDisabled) return;
        selectGender('male', this);
    });
    
    // Female button click handler
    femaleBtn.addEventListener('click', function() {
        if (buttonsDisabled) return;
        selectGender('female', this);
    });
    
    // Function to handle gender selection
    function selectGender(gender, element) {
        // Remove active class from previous selection
        if (activeCard) activeCard.classList.remove('active', 'selected');
        
        // Add active class to new selection
        element.classList.add('active', 'selected');
        activeCard = element;
        
        // Add haptic feedback
        if ('vibrate' in navigator) {
            navigator.vibrate(50);
        }
        
        // Play selection sound
        const audio = new Audio('data:audio/mp3;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4Ljc2LjEwMAAAAAAAAAAAAAAA/+M4wAAAAAAAAAAAAEluZm8AAAAPAAAAAwAABPEAVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVaqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqv///////////////////////////////////////////8AAAAATGF2YzU4LjEzAAAAAAAAAAAAAAAAJAYHf/7UGQAAAKdHPO0sMQAAAAA/wAAABFfEFY9kxngAAAD/AAAAEAAA9RsrcrAYf/7cGQAAAOJG1nGYG+AAAAA/wAAABHkbVkZMZ5AAAAA/wAAABP//R5f/4J///+CWluiKnIZuQpgXf/7UGQAAANBHVZGYMeAAAAA/wAAABH0fV4ZIx4AAAAA/wAAABHAJdJxSJMTz0f/Bmd25SjnKmNocA3//4JvXYM0CCRyB/+hEbF//QZ1y2Tmv/eI6P/9BnUWHDtw');
        audio.volume = 0.2;
        audio.play().catch(e => console.log('Audio play prevented:', e));
        
        setTimeout(() => {
            // Disable buttons during processing
            disableButtons(true);
            
            // Send gender selection to client
            sendGenderSelection(gender);
        }, 600);
    }
    
    // Close button click handler
    closeBtn.addEventListener('click', function() {
        if (buttonsDisabled) return;
        
        // Add click effect
        this.classList.add('clicked');
        
        setTimeout(() => {
            this.classList.remove('clicked');
            closeUI();
            disableButtons(true);
        }, 200);
    });
    
    // ESC key to close the UI
    document.addEventListener('keyup', function(event) {
        if (event.key === 'Escape' && displayingUI) {
            closeUI();
        }
    });
    
    // Function to disable/enable buttons during processing
    function disableButtons(disabled) {
        buttonsDisabled = disabled;
        
        // Visual feedback
        const elements = [maleBtn, femaleBtn, closeBtn];
        
        elements.forEach(el => {
            if (disabled) {
                el.classList.add('disabled');
                el.setAttribute('aria-disabled', 'true');
            } else {
                el.classList.remove('disabled');
                el.setAttribute('aria-disabled', 'false');
            }
        });
        
        closeBtn.disabled = disabled;
    }
    
    // Function to send gender selection to client
    function sendGenderSelection(gender) {
        fetch('https://gender_select/selectGender', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                gender: gender
            })
        })
        .then(response => response.json())
        .then(data => {
            console.log('Gender selection processed:', data);
        })
        .catch(error => {
            console.error('Error processing gender selection:', error);
            disableButtons(false);
            
            // Show error message
            const errorMsg = document.createElement('div');
            errorMsg.className = 'error-message';
            errorMsg.textContent = 'Failed to process selection. Please try again.';
            document.querySelector('.panel-content').appendChild(errorMsg);
            
            setTimeout(() => {
                errorMsg.remove();
            }, 3000);
        });
    }
    
    // Function to close the UI
    function closeUI() {
        fetch('https://gender_select/closeUI', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        })
        .then(response => response.json())
        .catch(error => {
            console.error('Error closing UI:', error);
        });
    }
});
