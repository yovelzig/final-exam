# שלב ראשון: שימוש בתמונה רזה של פייתון
FROM python:3.9-slim AS builder

# הגדרת משתנה סביבתי למיקום העבודה
WORKDIR /app

# העתקת קובץ הדרישות והתקנת התלויות
COPY ./requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

# שלב שני: יצירת התמונה הסופית
FROM python:3.9-slim

# הגדרת משתנה סביבתי למיקום העבודה
WORKDIR /app

# העתקת קבצי האפליקציה
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

# חשיפת פורט 5001
EXPOSE 5001

# הפעלת האפליקציה
CMD ["python", "app.py"]
