// Firebase Configuration
const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const auth = firebase.auth();

// Check authentication
auth.onAuthStateChanged((user) => {
    if (!user) {
        window.location.href = 'login.html';
    } else {
        loadDashboard();
    }
});

// Navigation
function showSection(sectionId) {
    // Hide all sections
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Show selected section
    document.getElementById(sectionId).classList.add('active');
    
    // Update active menu item
    document.querySelectorAll('.sidebar-menu a').forEach(link => {
        link.classList.remove('active');
    });
    event.target.classList.add('active');
    
    // Update page title
    const titles = {
        'dashboard': 'Dashboard',
        'categories': 'Categories',
        'questions': 'Questions',
        'users': 'Users',
        'withdrawals': 'Withdrawals',
        'settings': 'Settings'
    };
    document.getElementById('page-title').textContent = titles[sectionId] || 'Dashboard';
    
    // Load section data
    switch(sectionId) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'categories':
            loadCategories();
            break;
        case 'questions':
            loadQuestions();
            break;
        case 'users':
            loadUsers();
            break;
        case 'withdrawals':
            loadWithdrawals();
            break;
        case 'settings':
            loadSettings();
            break;
    }
}

// Dashboard
async function loadDashboard() {
    try {
        // Load total users
        const usersSnapshot = await db.collection('users').get();
        document.getElementById('total-users').textContent = usersSnapshot.size;
        
        // Load total questions (approximate)
        let totalQuestions = 0;
        const categoriesSnapshot = await db.collection('categories').get();
        for (const categoryDoc of categoriesSnapshot.docs) {
            const chaptersSnapshot = await db.collection('categories')
                .doc(categoryDoc.id)
                .collection('chapters')
                .get();
            for (const chapterDoc of chaptersSnapshot.docs) {
                const questionsSnapshot = await db.collection('categories')
                    .doc(categoryDoc.id)
                    .collection('chapters')
                    .doc(chapterDoc.id)
                    .collection('questions')
                    .get();
                totalQuestions += questionsSnapshot.size;
            }
        }
        document.getElementById('total-questions').textContent = totalQuestions;
        
        // Load pending withdrawals
        const withdrawalsSnapshot = await db.collection('withdrawals')
            .where('status', '==', 'pending')
            .get();
        document.getElementById('pending-withdrawals').textContent = withdrawalsSnapshot.size;
        
        // Calculate total earnings (sum of all withdrawals)
        let totalEarnings = 0;
        const allWithdrawals = await db.collection('withdrawals')
            .where('status', '==', 'approved')
            .get();
        allWithdrawals.forEach(doc => {
            totalEarnings += doc.data().amount || 0;
        });
        document.getElementById('total-earnings').textContent = `₹${totalEarnings}`;
    } catch (error) {
        console.error('Error loading dashboard:', error);
    }
}

// Categories
async function loadCategories() {
    try {
        const snapshot = await db.collection('categories')
            .orderBy('order')
            .get();
        
        const tbody = document.getElementById('categories-table');
        tbody.innerHTML = '';
        
        snapshot.forEach(doc => {
            const data = doc.data();
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${data.name || ''}</td>
                <td>${data.order || 0}</td>
                <td>${data.chapterCount || 0}</td>
                <td>
                    <button class="btn btn-primary btn-sm" onclick="editCategory('${doc.id}')">Edit</button>
                    <button class="btn btn-danger btn-sm" onclick="deleteCategory('${doc.id}')">Delete</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Error loading categories:', error);
    }
}

function showAddCategoryModal() {
    document.getElementById('category-modal').style.display = 'block';
    document.getElementById('category-form').reset();
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

document.getElementById('category-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const name = document.getElementById('category-name').value;
    const order = parseInt(document.getElementById('category-order').value);
    
    try {
        await db.collection('categories').add({
            name: name,
            order: order,
            createdAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        alert('Category added successfully!');
        closeModal('category-modal');
        loadCategories();
    } catch (error) {
        console.error('Error adding category:', error);
        alert('Error adding category');
    }
});

// Questions
async function loadQuestions() {
    const categoryId = document.getElementById('category-select').value;
    const chapterId = document.getElementById('chapter-select').value;
    
    if (!categoryId || !chapterId) {
        document.getElementById('questions-table').innerHTML = 
            '<tr><td colspan="5">Please select category and chapter</td></tr>';
        return;
    }
    
    try {
        const snapshot = await db.collection('categories')
            .doc(categoryId)
            .collection('chapters')
            .doc(chapterId)
            .collection('questions')
            .orderBy('order')
            .get();
        
        const tbody = document.getElementById('questions-table');
        tbody.innerHTML = '';
        
        snapshot.forEach(doc => {
            const data = doc.data();
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${data.question || ''}</td>
                <td>${(data.options || []).join(', ')}</td>
                <td>${data.correctAnswer || ''}</td>
                <td>${data.order || 0}</td>
                <td>
                    <button class="btn btn-primary btn-sm" onclick="editQuestion('${doc.id}')">Edit</button>
                    <button class="btn btn-danger btn-sm" onclick="deleteQuestion('${doc.id}')">Delete</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Error loading questions:', error);
    }
}

// Load categories for dropdown
async function loadCategoryDropdown() {
    try {
        const snapshot = await db.collection('categories').get();
        const select = document.getElementById('category-select');
        select.innerHTML = '<option value="">Select Category</option>';
        
        snapshot.forEach(doc => {
            const option = document.createElement('option');
            option.value = doc.id;
            option.textContent = doc.data().name || doc.id;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading categories:', error);
    }
}

// Users
async function loadUsers() {
    try {
        const snapshot = await db.collection('users').get();
        const tbody = document.getElementById('users-table');
        tbody.innerHTML = '';
        
        snapshot.forEach(doc => {
            const data = doc.data();
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${data.name || 'N/A'}</td>
                <td>${data.email || 'N/A'}</td>
                <td>${data.phone || 'N/A'}</td>
                <td>${data.currentChapter || 1}</td>
                <td>${data.goldCoins || 0}</td>
                <td>₹${data.cashBalance || 0}</td>
                <td>
                    <button class="btn btn-primary btn-sm" onclick="viewUser('${doc.id}')">View</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Error loading users:', error);
    }
}

// Withdrawals
async function loadWithdrawals() {
    try {
        const snapshot = await db.collection('withdrawals')
            .orderBy('requestedAt', 'desc')
            .get();
        
        const tbody = document.getElementById('withdrawals-table');
        tbody.innerHTML = '';
        
        snapshot.forEach(doc => {
            const data = doc.data();
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${data.userId || 'N/A'}</td>
                <td>${data.amount || 0}</td>
                <td>${data.bankName || 'N/A'}</td>
                <td>${data.requestedAt ? new Date(data.requestedAt.toDate()).toLocaleDateString() : 'N/A'}</td>
                <td><span class="badge ${data.status === 'approved' ? 'bg-success' : data.status === 'rejected' ? 'bg-danger' : 'bg-warning'}">${data.status || 'pending'}</span></td>
                <td>
                    ${data.status === 'pending' ? `
                        <button class="btn btn-success btn-sm" onclick="approveWithdrawal('${doc.id}')">Approve</button>
                        <button class="btn btn-danger btn-sm" onclick="rejectWithdrawal('${doc.id}')">Reject</button>
                    ` : ''}
                </td>
            `;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Error loading withdrawals:', error);
    }
}

async function approveWithdrawal(withdrawalId) {
    if (!confirm('Are you sure you want to approve this withdrawal?')) return;
    
    try {
        await db.collection('withdrawals').doc(withdrawalId).update({
            status: 'approved',
            approvedAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        alert('Withdrawal approved successfully!');
        loadWithdrawals();
    } catch (error) {
        console.error('Error approving withdrawal:', error);
        alert('Error approving withdrawal');
    }
}

async function rejectWithdrawal(withdrawalId) {
    if (!confirm('Are you sure you want to reject this withdrawal?')) return;
    
    try {
        await db.collection('withdrawals').doc(withdrawalId).update({
            status: 'rejected',
            rejectedAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        alert('Withdrawal rejected');
        loadWithdrawals();
    } catch (error) {
        console.error('Error rejecting withdrawal:', error);
        alert('Error rejecting withdrawal');
    }
}

// Settings
async function loadSettings() {
    try {
        const doc = await db.collection('app_config').doc('website').get();
        if (doc.exists) {
            const data = doc.data();
            document.getElementById('apk-url').value = data.apkUrl || '';
            document.getElementById('hero-text').value = data.heroText || '';
        }
    } catch (error) {
        console.error('Error loading settings:', error);
    }
}

async function saveSettings() {
    try {
        await db.collection('app_config').doc('website').set({
            apkUrl: document.getElementById('apk-url').value,
            heroText: document.getElementById('hero-text').value,
            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        alert('Settings saved successfully!');
    } catch (error) {
        console.error('Error saving settings:', error);
        alert('Error saving settings');
    }
}

// Logout
function logout() {
    auth.signOut().then(() => {
        window.location.href = 'login.html';
    });
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadCategoryDropdown();
    document.getElementById('category-select').addEventListener('change', async () => {
        const categoryId = document.getElementById('category-select').value;
        const chapterSelect = document.getElementById('chapter-select');
        chapterSelect.innerHTML = '<option value="">Select Chapter</option>';
        
        if (categoryId) {
            try {
                const snapshot = await db.collection('categories')
                    .doc(categoryId)
                    .collection('chapters')
                    .orderBy('chapterNumber')
                    .get();
                
                snapshot.forEach(doc => {
                    const option = document.createElement('option');
                    option.value = doc.id;
                    option.textContent = `Chapter ${doc.data().chapterNumber || ''}`;
                    chapterSelect.appendChild(option);
                });
            } catch (error) {
                console.error('Error loading chapters:', error);
            }
        }
    });
    
    document.getElementById('chapter-select').addEventListener('change', loadQuestions);
});

