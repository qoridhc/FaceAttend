import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

# 1. 파이어베이스 디비에서 json 데이터 리스닝 & 원하는 데이터 뽑아내기
# 2. 리얼타임디비 경로는 파이썬과 플러터앱 둘 다 동일
# 3. 리스너 모듈 구현
# 4. 네트워크 연걸 예외처리 구현
# 5. 리스너 하고 있다가 기준에 부합한 새로운 데이터 발견시, 발견 여부 눈에 보이도록 알 수 있어야 함
# 6. 사진을 잘못 찍어서 다시 업로드 할 경우 판단 기준 있어야 함



#Class FirebaseDB(singleton)
#function basic structure
#
#def <func name>([database path], [method for data])
class FirebaseDB:
    a = 0
    _instance = None
    sdk_path = 'firebaseAccountKey.json'
    url = 'https://facepractice-fd93d-default-rtdb.firebaseio.com'
    _ref = None
    query = None

    #class 생성
    @classmethod
    def getInstance(cls, path, *args, **kwargs):
        #_instance가 없으면 생성
        if not cls._instance:
            cls._instance = FirebaseDB(path)
        return cls._instance

    def __init__(self, path):
        cred = credentials.Certificate(self.sdk_path)
        firebase_admin.initialize_app(cred, {'databaseURL': self.url})
        self._ref = db.reference(path)

    #정보 업데이트
    def update(self, db_path, data):
        self._ref.update({db_path : data})
        print('update 성공')

    #디비 정보 받기
    def value_get(self):
        return self._ref.get()

    #child 정보 가져오기
    def child(self, childpath):
        return self._ref.child(childpath)

    #push
    def push(self, str):
        self._ref.push(str)

    #set
    def set(self, value):
        self._ref.set(value)

    #delete
    def delete(self):
        self._ref.delete()

    # get_if_changed
    def get_if_changed(self, etag):
        return self._ref.get_if_changed(etag)

     # listen
    def listen(self, callback):
        return self._ref.listen(callback)

    # order_by_child
    def order_by_child(self, path):
        return self._ref.order_by_child(path)

    # order_by_key
    def order_by_key(self):
        return self._ref.order_by_key()

    # order_by_value
    def order_by_value(self):
        return self._ref.order_by_value()

    # set_if_unchanged
    def set_if_unchanged(self, expected_etag, value):
        return self._ref.set_if_unchanged(expected_etag, value)

    #transaction
    def transaction(self, transation_update):
        return self._ref.transaction(transation_update)

    #Query
    #start_at
    def start_at(self, start):
        query = db.Query()
        return self.query.start_at(start)

    #end_at
    def end_at(self, end):
        query = db.Query()
        return self.query.end_at(end)

    #equal_to
    def equal_to(self, value):
        query = db.Query()
        return self.query.equal_to(value)

    #limit_to_first
    def limit_to_first(self, limit):
        query = db.Query()
        return self.query.limit_to_first(limit)

    # limit_to_end
    def limit_to_last(self, limit):
        query = db.Query()
        return self.query.limit_to_last(limit)

    def query_get(self):
        query = db.Query()
        return self.query.get()