// Dashboard functionality
let currentUser = null;
let userData = null;
let categories = [];
let selectedCategory = null;

// Initialize dashboard
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
                await loadUserData();
                await loadCategories();
            } else {
                window.location.href = 'login.html';
            }
        });
    } else {
        document.body.innerHTML = '<div class="loading"><p>Firebase configuration not found.</p></div>';
    }
});

async function loadUserData() {
    try {
        const userDoc = await db.collection('users').doc(currentUser.uid).get();
        
        if (userDoc.exists) {
            userData = userDoc.data();
            
            // Update UI
            document.getElementById('user-name').textContent = userData.name || userData.email;
            document.getElementById('cash-balance').textContent = `₹${userData.cashBalance || 0}`;
            document.getElementById('gold-coins').textContent = userData.goldCoins || 0;
            document.getElementById('current-chapter').textContent = userData.currentChapter || 1;
            document.getElementById('completed-count').textContent = (userData.completedChapters || []).length;
        } else {
            // Create user document if doesn't exist
            await createUserDocument();
            await loadUserData();
        }
    } catch (error) {
        console.error('Error loading user data:', error);
    }
}

async function createUserDocument() {
    const userData = {
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName || '',
        phone: currentUser.phoneNumber || '',
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
        lastLogin: firebase.firestore.FieldValue.serverTimestamp(),
        currentChapter: 1,
        completedChapters: [],
        goldCoins: 0,
        cashBalance: 0,
        totalEarnings: 0,
        isVerified: false,
        platform: 'web'
    };

    await db.collection('users').doc(currentUser.uid).set(userData);
}

async function loadCategories() {
    try {
        const categoriesSnapshot = await db.collection('categories').orderBy('order', 'asc').get();
        categories = [];
        
        categoriesSnapshot.forEach(doc => {
            categories.push({
                id: doc.id,
                ...doc.data()
            });
        });

        displayCategories();
        
        // Load chapters for first category by default
        if (categories.length > 0) {
            selectedCategory = categories[0].id;
            await loadChapters(selectedCategory);
        }
    } catch (error) {
        console.error('Error loading categories:', error);
        document.getElementById('categories-grid').innerHTML = '<p style="color: var(--text-secondary);">No categories found.</p>';
    }
}

function displayCategories() {
    const grid = document.getElementById('categories-grid');
    
    if (categories.length === 0) {
        grid.innerHTML = '<p style="color: var(--text-secondary);">No categories available.</p>';
        return;
    }

    grid.innerHTML = categories.map(cat => `
        <div class="category-card" onclick="selectCategory('${cat.id}')">
            <h3>${cat.name}</h3>
            <p>${cat.description || ''}</p>
        </div>
    `).join('');
}

async function selectCategory(categoryId) {
    selectedCategory = categoryId;
    await loadChapters(categoryId);
    
    // Update active category
    document.querySelectorAll('.category-card').forEach(card => {
        card.style.borderColor = 'rgba(203, 254, 28, 0.1)';
    });
    event.currentTarget.style.borderColor = 'var(--primary-color)';
}

async function loadChapters(categoryId) {
    try {
        const chaptersSnapshot = await db.collection('categories').doc(categoryId)
            .collection('chapters').orderBy('chapterNumber', 'asc').get();
        
        const chapters = [];
        chaptersSnapshot.forEach(doc => {
            chapters.push({
                id: doc.id,
                ...doc.data()
            });
        });

        displayChapters(chapters);
    } catch (error) {
        console.error('Error loading chapters:', error);
        document.getElementById('chapters-list').innerHTML = '<p style="color: var(--text-secondary);">No chapters found.</p>';
    }
}

function displayChapters(chapters) {
    const list = document.getElementById('chapters-list');
    const currentChapter = userData?.currentChapter || 1;
    const completedChapters = userData?.completedChapters || [];

    if (chapters.length === 0) {
        list.innerHTML = '<p style="color: var(--text-secondary);">No chapters available for this category.</p>';
        return;
    }

    list.innerHTML = chapters.map(chapter => {
        const chapterNum = chapter.chapterNumber || 1;
        const isLocked = chapterNum > currentChapter;
        const isCompleted = completedChapters.includes(chapterNum);
        
        let rewardText = '';
        if (chapterNum === 1) {
            rewardText = 'Reward: ₹20 Cash';
        } else if (chapterNum >= 11 && chapterNum <= 50) {
            rewardText = 'Reward: 15 Gold Coins';
        }

        return `
            <div class="chapter-item ${isLocked ? 'locked' : ''} ${isCompleted ? 'completed' : ''}">
                <div class="chapter-info">
                    <h4>Chapter ${chapterNum}${isCompleted ? ' ✓' : ''}</h4>
                    <p>${chapter.title || 'Quiz Chapter'} | ${rewardText}</p>
                </div>
                <button class="btn-start" 
                    onclick="startQuiz(${chapterNum}, '${selectedCategory}')" 
                    ${isLocked ? 'disabled' : ''}>
                    ${isLocked ? 'Locked' : isCompleted ? 'Retry' : 'Start'}
                </button>
            </div>
        `;
    }).join('');
}

function startQuiz(chapterNumber, categoryId) {
    // Store quiz info in sessionStorage
    sessionStorage.setItem('quizChapter', chapterNumber);
    sessionStorage.setItem('quizCategory', categoryId);
    
    // Redirect to quiz page
    window.location.href = `quiz.html?chapter=${chapterNumber}&category=${categoryId}`;
}

// Make functions globally available
window.selectCategory = selectCategory;
window.startQuiz = startQuiz;

