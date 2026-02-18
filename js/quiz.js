// Quiz functionality with full screen mode and cheat detection
let currentUser = null;
let db = null;
let questions = [];
let currentQuestionIndex = 0;
let selectedAnswer = null;
let timer = null;
let timeLeft = 20;
let score = 0;
let quizChapter = 1;
let quizCategory = null;
let isFullscreen = false;
let windowBlurred = false;

// Initialize quiz
window.addEventListener('configLoaded', async function() {
    const config = window.ExamEarnConfig;
    
    if (config.firebaseConfig && config.firebaseConfig.apiKey) {
        firebaseApp = firebase.initializeApp(config.firebaseConfig);
        auth = firebase.auth();
        db = firebase.firestore();
        
        // Check authentication
        auth.onAuthStateChanged(async (user) => {
            if (user) {
                currentUser = user;
                
                // Get quiz parameters from URL
                const urlParams = new URLSearchParams(window.location.search);
                quizChapter = parseInt(urlParams.get('chapter')) || 1;
                quizCategory = urlParams.get('category') || null;
                
                // Enter fullscreen mode
                requestFullscreen();
                
                // Load quiz questions
                await loadQuiz();
            } else {
                window.location.href = 'login.html';
            }
        });
    } else {
        document.body.innerHTML = '<div class="loading"><p>Firebase configuration not found.</p></div>';
    }
});

// Fullscreen mode functions
function requestFullscreen() {
    const elem = document.documentElement;
    
    if (elem.requestFullscreen) {
        elem.requestFullscreen().then(() => {
            isFullscreen = true;
            document.body.classList.add('fullscreen');
            document.getElementById('fullscreen-warning').classList.remove('show');
        }).catch(err => {
            console.error('Fullscreen error:', err);
            showFullscreenWarning();
        });
    } else if (elem.webkitRequestFullscreen) {
        elem.webkitRequestFullscreen();
    } else if (elem.msRequestFullscreen) {
        elem.msRequestFullscreen();
    } else {
        showFullscreenWarning();
    }
}

function showFullscreenWarning() {
    document.getElementById('fullscreen-warning').classList.add('show');
}

// Detect window blur (tab switch)
document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
        windowBlurred = true;
        handleCheatAttempt();
    } else {
        windowBlurred = false;
    }
});

// Detect fullscreen change
document.addEventListener('fullscreenchange', function() {
    isFullscreen = !document.fullscreenElement;
    if (!isFullscreen && questions.length > 0) {
        handleCheatAttempt();
    }
});

function handleCheatAttempt() {
    // Auto fail on cheat attempt
    clearInterval(timer);
    showResult(false, 'Quiz failed due to window switch or fullscreen exit!');
}

async function loadQuiz() {
    try {
        // Determine question count and timer based on chapter
        const questionCount = quizChapter === 1 ? 10 : 20;
        timeLeft = quizChapter === 1 ? 20 : 10;
        
        // Load questions from Firestore
        let questionsRef = db.collection('categories').doc(quizCategory)
            .collection('chapters').where('chapterNumber', '==', quizChapter)
            .limit(1);
        
        const chapterSnapshot = await questionsRef.get();
        
        if (chapterSnapshot.empty) {
            document.getElementById('question-card').innerHTML = '<p>Chapter not found.</p>';
            return;
        }
        
        const chapterDoc = chapterSnapshot.docs[0];
        const chapterData = chapterDoc.data();
        
        // Get questions for this chapter
        const questionsSnapshot = await db.collection('categories').doc(quizCategory)
            .collection('chapters').doc(chapterDoc.id)
            .collection('questions')
            .limit(questionCount)
            .get();
        
        questions = [];
        questionsSnapshot.forEach(doc => {
            questions.push({
                id: doc.id,
                ...doc.data()
            });
        });
        
        // Shuffle questions
        questions = shuffleArray(questions);
        
        if (questions.length === 0) {
            document.getElementById('question-card').innerHTML = '<p>No questions available for this chapter.</p>';
            return;
        }
        
        // Start quiz
        displayQuestion();
    } catch (error) {
        console.error('Error loading quiz:', error);
        document.getElementById('question-card').innerHTML = '<p>Error loading quiz. Please try again.</p>';
    }
}

function shuffleArray(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
}

function displayQuestion() {
    if (currentQuestionIndex >= questions.length) {
        // Quiz completed
        finishQuiz();
        return;
    }
    
    const question = questions[currentQuestionIndex];
    selectedAnswer = null;
    timeLeft = quizChapter === 1 ? 20 : 10;
    
    // Update UI
    document.getElementById('question-number').textContent = 
        `Question ${currentQuestionIndex + 1} of ${questions.length}`;
    document.getElementById('progress-fill').style.width = 
        `${((currentQuestionIndex + 1) / questions.length) * 100}%`;
    
    // Display question
    const questionCard = document.getElementById('question-card');
    questionCard.innerHTML = `
        <div class="question-text">${question.question}</div>
        <div class="options-list">
            ${question.options.map((option, index) => `
                <button class="option-btn" onclick="selectOption(${index})" id="option-${index}">
                    ${option}
                </button>
            `).join('')}
        </div>
    `;
    
    // Start timer
    startTimer();
    
    // Enable next button after selection
    document.getElementById('btn-next').disabled = true;
}

function selectOption(index) {
    if (selectedAnswer !== null) return; // Already answered
    
    selectedAnswer = index;
    
    // Disable all options
    document.querySelectorAll('.option-btn').forEach(btn => {
        btn.disabled = true;
    });
    
    // Highlight selected
    document.getElementById(`option-${index}`).classList.add('selected');
    
    // Check answer
    const question = questions[currentQuestionIndex];
    const isCorrect = index === question.correctAnswer;
    
    if (isCorrect) {
        document.getElementById(`option-${index}`).classList.add('correct');
        score++;
    } else {
        document.getElementById(`option-${index}`).classList.add('wrong');
        // Show correct answer
        document.getElementById(`option-${question.correctAnswer}`).classList.add('correct');
    }
    
    // Stop timer
    clearInterval(timer);
    
    // Enable next button
    document.getElementById('btn-next').disabled = false;
}

function startTimer() {
    document.getElementById('timer').textContent = timeLeft;
    document.getElementById('timer').className = 'timer';
    
    timer = setInterval(() => {
        timeLeft--;
        document.getElementById('timer').textContent = timeLeft;
        
        if (timeLeft <= 5) {
            document.getElementById('timer').classList.add('danger');
        } else if (timeLeft <= 10) {
            document.getElementById('timer').classList.add('warning');
        }
        
        if (timeLeft <= 0) {
            clearInterval(timer);
            // Time's up - auto select (wrong answer)
            if (selectedAnswer === null) {
                selectOption(-1); // Force wrong answer
            }
        }
    }, 1000);
}

function nextQuestion() {
    currentQuestionIndex++;
    displayQuestion();
}

function finishQuiz() {
    clearInterval(timer);
    
    const percentage = (score / questions.length) * 100;
    const passed = percentage >= 60;
    
    // Calculate reward
    let reward = '';
    if (passed) {
        if (quizChapter === 1) {
            reward = '₹20 Cash';
        } else if (quizChapter >= 11 && quizChapter <= 50) {
            reward = '15 Gold Coins';
        }
    }
    
    // Update user data in Firestore
    updateUserProgress(passed, reward);
    
    // Show result
    showResult(passed, reward);
}

async function updateUserProgress(passed, reward) {
    try {
        const userRef = db.collection('users').doc(currentUser.uid);
        const userDoc = await userRef.get();
        const userData = userDoc.data();
        
        const updates = {};
        
        if (passed) {
            // Add to completed chapters if not already completed
            const completedChapters = userData.completedChapters || [];
            if (!completedChapters.includes(quizChapter)) {
                updates.completedChapters = [...completedChapters, quizChapter];
            }
            
            // Update current chapter
            if (quizChapter >= userData.currentChapter) {
                updates.currentChapter = quizChapter + 1;
            }
            
            // Add reward
            if (quizChapter === 1) {
                updates.cashBalance = (userData.cashBalance || 0) + 20;
                updates.totalEarnings = (userData.totalEarnings || 0) + 20;
            } else if (quizChapter >= 11 && quizChapter <= 50) {
                updates.goldCoins = (userData.goldCoins || 0) + 15;
            }
        }
        
        if (Object.keys(updates).length > 0) {
            await userRef.update(updates);
        }
    } catch (error) {
        console.error('Error updating user progress:', error);
    }
}

function showResult(passed, reward) {
    const modal = document.getElementById('result-modal');
    const title = document.getElementById('result-title');
    const scoreEl = document.getElementById('result-score');
    const rewardEl = document.getElementById('result-reward');
    
    title.textContent = passed ? '🎉 Quiz Passed!' : '❌ Quiz Failed';
    title.style.color = passed ? 'var(--success)' : 'var(--error)';
    scoreEl.textContent = `${score}/${questions.length}`;
    rewardEl.textContent = passed ? `Reward: ${reward}` : 'Minimum 60% required to pass';
    
    modal.classList.add('show');
}

function goToDashboard() {
    // Exit fullscreen
    if (document.exitFullscreen) {
        document.exitFullscreen();
    }
    
    window.location.href = 'dashboard.html';
}

// Make functions globally available
window.selectOption = selectOption;
window.nextQuestion = nextQuestion;
window.goToDashboard = goToDashboard;

