import pandas as pd
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder

# Step 1: Load and clean data
df = pd.read_csv("firestore-export/tasks.csv")

df = df.dropna(subset=['completedDate'])  # Only keep completed tasks

# Step 2: Feature Engineering
df['assignedDate'] = pd.to_datetime(df['assignedDate'])
df['dueDate'] = pd.to_datetime(df['dueDate'])
df['completedDate'] = pd.to_datetime(df['completedDate'])

df['assignedTimestamp'] = df['assignedDate'].astype('int64') // 10**9
df['dueTimestamp'] = df['dueDate'].astype('int64') // 10**9
df['duration'] = (df['completedDate'] - df['assignedDate']).dt.days

# Step 3: Encode priority
encoder = LabelEncoder()
df['priority_encoded'] = encoder.fit_transform(df['priority'].fillna("medium"))

# Step 4: Prepare input/output
X = df[['assignedTimestamp', 'dueTimestamp', 'priority_encoded']]
y = df['duration']

# Step 5: Train/Test Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Step 6: Build Model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(64, activation='relu', input_shape=(3,)),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dense(1)
])

model.compile(optimizer='adam', loss='mse', metrics=['mae'])
model.fit(X_train, y_train, epochs=100, validation_split=0.1)

# Step 7: Save model and encoder classes
model.save("task_estimator_model")
import joblib
joblib.dump(encoder, 'priority_encoder.pkl')
