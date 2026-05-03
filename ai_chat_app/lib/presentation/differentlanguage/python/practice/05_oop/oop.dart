import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Python 面向对象编程 —— 第五课（完整扩展版）
class PythonOOP extends StatelessWidget {
  const PythonOOP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第5章 面向对象编程')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Paragraph(
              '面向对象编程（OOP）把相关的数据和函数打包成"对象"。'
              '如果编程是做菜，面向过程是"洗菜->切菜->炒菜"的步骤，'
              '面向对象则是把"菜刀、砧板、食材"各自封装成工具。',
            ),
            DividerLine(),

            // ===== 1. 类与对象基础 =====
            SectionHeader('类与对象基础', icon: Icons.widgets),
            Paragraph(
              '类（Class）是"模板"，对象是根据模板创建的"实例"。'
              '__init__ 是构造方法，创建对象时自动调用。self 代表"对象自己"。',
            ),
            CodeBlock(
              r'''class Student:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    def introduce(self):
        print(f"我叫{self.name}，今年{self.age}岁")
    def is_adult(self):
        return self.age >= 18

s1 = Student("小明", 18)
s2 = Student("小红", 16)
s1.introduce()                       # 我叫小明，今年18岁
s2.introduce()                       # 我叫小红，今年16岁
print(f"{s1.name}成年? {s1.is_adult()}")  # True
print(f"{s2.name}成年? {s2.is_adult()}")  # False
''',
              language: 'Python',
            ),
            OutputBox('我叫小明，今年18岁\n我叫小红，今年16岁\n小明成年? True\n小红成年? False'),
            TipBox(
              'self 代表"当前实例"，定义方法时第一个参数必须是 self，'
              '但调用时不需要传。这是约定，但强烈建议遵守。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ===== 2. 实例属性 vs 类属性 =====
            SectionHeader('实例属性 vs 类属性', icon: Icons.category),
            Paragraph(
              '类属性所有实例共享，在类体中直接赋值。实例属性每个对象独有，在 __init__ 中定义。'
              '通过实例访问时，Python 先查实例属性，找不到再查类属性——这叫"查找顺序"。',
            ),
            CodeBlock(
              r'''class Dog:
    species = "犬科"       # 类属性：所有实例共享
    count = 0
    def __init__(self, name):
        self.name = name   # 实例属性
        Dog.count += 1

d1 = Dog("旺财")
d2 = Dog("小白")

d1.species = "猫科"        # 创建同名实例属性，屏蔽类属性
print(d1.species)          # 猫科（实例优先）
print(d2.species)          # 犬科（仍为类属性）
print(Dog.species)         # 犬科（未变）

Dog.species = "哺乳动物"   # 修改类属性
print(d2.species)          # 哺乳动物（受影响）
print(d1.species)          # 猫科（被实例屏蔽）
print(f"共创建了{Dog.count}只狗")  # 2
''',
              language: 'Python',
            ),
            OutputBox(
              '猫科\n犬科\n犬科\n哺乳动物\n猫科\n共创建了2只狗',
            ),
            DividerLine(),

            // ===== 3. 魔术方法 =====
            SectionHeader('魔术方法', icon: Icons.auto_fix_high),
            Paragraph(
              '魔术方法以双下划线开头和结尾，在特定操作中被"自动"调用。'
              '例如 __str__（print 时调用）、__len__（len() 时）、__eq__（== 比较时）。',
            ),
            CodeBlock(
              r'''class Book:
    def __init__(self, title, pages):
        self.title = title
        self.pages = pages
    def __str__(self):
        return f"《{self.title}》"
    def __len__(self):
        return self.pages
    def __eq__(self, other):
        return self.title == other.title and self.pages == other.pages
    def __lt__(self, other):
        return self.pages < other.pages

b1 = Book("Python入门", 200)
b2 = Book("Python入门", 200)
b3 = Book("数据结构", 350)

print(b1)                     # 调用 __str__：《Python入门》
print(len(b1))                # 调用 __len__：200
print(b1 == b2)               # 调用 __eq__：True
print(b1 < b3)                # 调用 __lt__：True（200<350）
''',
              language: 'Python',
            ),
            OutputBox('《Python入门》\n200\nTrue\nTrue'),
            TipBox(
              '魔术方法让自定义对象用得像内置类型。'
              '实现 __add__ 支持 +，实现 __eq__ 支持 ==，实现 __len__ 支持 len()。'
              '这就是 Python 的"协议"思想。',
              type: TipType.info,
            ),
            DividerLine(),

            // ===== 4. @property 装饰器 =====
            SectionHeader('@property 装饰器', icon: Icons.shield),
            Paragraph(
              '@property 把方法调用变成属性访问，支持 setter（赋值验证）和 deleter。'
              '适合"计算后返回"或"赋值前验证"的场景。',
            ),
            CodeBlock(
              r'''class Temperature:
    def __init__(self, celsius=0):
        self._celsius = celsius    # 惯例：_ 开头表示私有

    @property
    def celsius(self):             # getter
        return self._celsius

    @celsius.setter
    def celsius(self, value):      # setter（带验证）
        if value < -273.15:
            raise ValueError("不能低于绝对零度")
        self._celsius = value

    @property
    def fahrenheit(self):          # 计算属性（只读）
        return round(self._celsius * 9/5 + 32, 1)

t = Temperature(25)
print(f"{t.celsius}°C = {t.fahrenheit}°F")  # 像属性一样访问
t.celsius = 100                              # 调用 setter
print(f"沸点: {t.celsius}°C / {t.fahrenheit}°F")
try:
    t.celsius = -300                         # 触发验证
except ValueError as e:
    print(f"错误: {e}")
''',
              language: 'Python',
            ),
            OutputBox('25°C = 77.0°F\n沸点: 100°C / 212.0°F\n错误: 不能低于绝对零度'),
            DividerLine(),

            // ===== 5. @classmethod 工厂方法 =====
            SectionHeader('类方法 @classmethod', icon: Icons.factory),
            Paragraph(
              '类方法用 @classmethod 装饰，第一个参数是 cls（代表类本身）。'
              '不依赖实例，可通过"类名.方法()"直接调用。最常见的用途是"工厂方法"。',
            ),
            CodeBlock(
              r'''import datetime

class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    @classmethod
    def from_birth_year(cls, name, birth_year):
        """工厂方法：通过出生年份创建"""
        age = datetime.date.today().year - birth_year
        return cls(name, age)     # cls 自动绑定为当前类

    @classmethod
    def from_dict(cls, data):
        return cls(data["name"], data["age"])

    def __str__(self):
        return f"{self.name}({self.age}岁)"

p1 = Person("小明", 20)                          # 普通构造
p2 = Person.from_birth_year("小红", 2008)        # 出生年份
p3 = Person.from_dict({"name": "小刚", "age": 25})  # 字典

print(p1)   # 小明(20岁)
print(p2)   # 小红(18岁)
print(p3)   # 小刚(25岁)
''',
              language: 'Python',
            ),
            OutputBox('小明(20岁)\n小红(18岁)\n小刚(25岁)'),
            TipBox(
              '工厂方法让调用者不需要知道构造细节，只需调用有意义的类方法名。'
              'cls 自动绑定到调用时的类，子类继承时也能正确创建子类实例。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ===== 6. @staticmethod 工具方法 =====
            SectionHeader('静态方法 @staticmethod', icon: Icons.handyman),
            Paragraph(
              '静态方法用 @staticmethod 装饰，不需要 self 或 cls。'
              '本质是普通函数，放在类的命名空间里，适合做"工具方法"。',
            ),
            CodeBlock(
              r'''class StringUtils:
    @staticmethod
    def is_palindrome(s):
        cleaned = s.lower().replace(" ", "")
        return cleaned == cleaned[::-1]

    @staticmethod
    def count_vowels(s):
        return sum(1 for c in s.lower() if c in "aeiou")

    @staticmethod
    def reverse_words(s):
        return " ".join(s.split()[::-1])

    @staticmethod
    def to_camel_case(s):
        parts = s.split("_")
        return parts[0] + "".join(p.capitalize() for p in parts[1:])

print(StringUtils.is_palindrome("A man a plan a canal Panama"))  # True
print(StringUtils.reverse_words("Python is awesome"))            # awesome is Python
print(StringUtils.to_camel_case("user_name"))                    # userName
''',
              language: 'Python',
            ),
            OutputBox('True\nawesome is Python\nuserName'),
            TipBox(
              '静态方法不知道类和实例的任何信息，只是恰好放在类的命名空间里。'
              '当你不需要类或实例信息时，就用静态方法。',
              type: TipType.info,
            ),
            DividerLine(),

            // ===== 7. 继承 =====
            SectionHeader('继承', icon: Icons.family_restroom),
            Paragraph(
              '子类继承父类的属性和方法，可"重写"父类方法。super() 调用父类方法。'
              'MRO（方法解析顺序）决定多重继承的查找路径。isinstance / issubclass 做类型检查。',
            ),
            CodeBlock(
              r'''class Animal:
    def __init__(self, name):
        self.name = name
    def speak(self):
        print(f"{self.name}发出声音")

class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name)        # 调用父类构造
        self.breed = breed
    def speak(self):                  # 方法重写
        print(f"{self.name}汪汪叫！")

class Cat(Animal):
    def __init__(self, name, color):
        super().__init__(name)
        self.color = color
    def speak(self):
        print(f"{self.name}喵喵叫！")

# 多重继承
class FlyMixin:
    def fly(self):
        print(f"{self.name}在飞翔")

class Duck(Animal, FlyMixin):
    pass

dog = Dog("旺财", "金毛")
cat = Cat("咪咪", "橘色")
duck = Duck("唐老鸭")

dog.speak()                    # 旺财汪汪叫！
cat.speak()                    # 咪咪喵喵叫！
duck.fly()                     # 唐老鸭在飞翔
print(isinstance(dog, Animal)) # True
print(issubclass(Dog, Animal)) # True
print(f"MRO: {[c.__name__ for c in Duck.__mro__]}")
''',
              language: 'Python',
            ),
            OutputBox(
              '旺财汪汪叫！\n'
              '咪咪喵喵叫！\n'
              '唐老鸭在飞翔\n'
              'True\n'
              'True\n'
              "MRO: ['Duck', 'Animal', 'FlyMixin', 'object']",
            ),
            TipBox(
              'MRO 使用 C3 线性化算法，按从左到右查找。super() 遵循 MRO，'
              '而非简单的"父类"——这正是多重继承能正确协作的原因。',
              type: TipType.info,
            ),
            DividerLine(),

            // ===== 8. dataclass 数据类 =====
            SectionHeader('dataclass 数据类', icon: Icons.data_object),
            Paragraph(
              'Python 3.7+ 的 @dataclass 自动生成 __init__、__repr__、__eq__ 等样板代码。'
              'frozen=True 创建不可变对象，field() 控制字段行为，__post_init__ 做初始化验证。',
            ),
            CodeBlock(
              r'''from dataclasses import dataclass, field
from typing import List

@dataclass
class Book:
    title: str
    author: str
    year: int
    pages: int = 0
    tags: List[str] = field(default_factory=list)  # 必须用 factory

    def __post_init__(self):
        if self.year < 0:
            raise ValueError("年份不能为负")

@dataclass(frozen=True)
class Point:
    x: float
    y: float
    def distance(self):
        return (self.x**2 + self.y**2) ** 0.5

b1 = Book("Python实战", "张三", 2024, 400, ["编程"])
b2 = Book("Python实战", "张三", 2024, 400, ["编程"])
print(b1)                          # 自动 __repr__
print(f"b1 == b2: {b1 == b2}")     # 自动 __eq__

p = Point(3, 4)
print(f"距离: {p.distance():.2f}")  # 5.00
''',
              language: 'Python',
            ),
            OutputBox(
              "Book(title='Python实战', author='张三', year=2024, pages=400, tags=['编程'])\n"
              'b1 == b2: True\n'
              '距离: 5.00',
            ),
            TipBox(
              'field(default_factory=list) 不可写成 field(default=[])，'
              '否则所有实例共享同一个列表——这是一个常见陷阱。',
              type: TipType.warning,
            ),
            DividerLine(),

            // ===== 9. 抽象基类 ABC =====
            SectionHeader('抽象基类 ABC', icon: Icons.account_tree),
            Paragraph(
              '抽象基类定义"接口规范"，@abstractmethod 装饰的方法子类必须实现，否则实例化报错。'
              '这就像一份"契约"：子类承诺实现这些方法。',
            ),
            CodeBlock(
              r'''from abc import ABC, abstractmethod
import math

class Shape(ABC):
    @abstractmethod
    def area(self):      pass
    @abstractmethod
    def perimeter(self): pass
    def describe(self):
        return f"面积: {self.area():.2f}, 周长: {self.perimeter():.2f}"

class Circle(Shape):
    def __init__(self, r):
        self.r = r
    def area(self):
        return math.pi * self.r ** 2
    def perimeter(self):
        return 2 * math.pi * self.r

class Rect(Shape):
    def __init__(self, w, h):
        self.w, self.h = w, h
    def area(self):
        return self.w * self.h
    def perimeter(self):
        return 2 * (self.w + self.h)

# shape = Shape()  # TypeError！不能实例化抽象类

for s in [Circle(5), Rect(3, 4)]:
    print(f"{s.__class__.__name__}: {s.describe()}")
''',
              language: 'Python',
            ),
            OutputBox(
              'Circle: 面积: 78.54, 周长: 31.42\n'
              'Rect: 面积: 12.00, 周长: 14.00',
            ),
            DividerLine(),

            // ===== 10. __slots__ 属性限制 =====
            SectionHeader('__slots__ 属性限制', icon: Icons.memory),
            Paragraph(
              '默认实例用 __dict__ 存储属性，可随时添加新属性。__slots__ 固定属性集合，'
              '① 防止拼写错误 ② 节省内存（无 __dict__）。创建大量对象时特别有用。',
            ),
            CodeBlock(
              r'''class Person:
    __slots__ = ("name", "age")   # 只允许这两个属性
    def __init__(self, name, age):
        self.name = name
        self.age = age

p = Person("小明", 20)
print(p.name, p.age)               # 正常访问

try:
    p.email = "x@test.com"         # 动态添加 — 报错
except AttributeError as e:
    print(f"禁止添加: {e}")

print(f"有 __dict__: {hasattr(p, '__dict__')}")  # False 节省内存

import sys
class Normal:
    def __init__(self, x, y):
        self.x, self.y = x, y

class Slotted:
    __slots__ = ("x", "y")
    def __init__(self, x, y):
        self.x, self.y = x, y

n = Normal(1, 2)
s = Slotted(1, 2)
print(f"普通: {sys.getsizeof(n)}B, __slots__: {sys.getsizeof(s)}B")
''',
              language: 'Python',
            ),
            OutputBox(
              '小明 20\n'
              "禁止添加: 'Person' object has no attribute 'email'\n"
              '有 __dict__: False\n'
              '普通: 56B, __slots__: 48B',
            ),
            TipBox(
              '子类也需要定义 __slots__ 才能完全生效。'
              '__slots__ 默认不与 __dict__ 共存（除非显式加入 __dict__）。',
              type: TipType.caution,
            ),
            DividerLine(),

            // ===== 11. 运算符重载 =====
            SectionHeader('运算符重载', icon: Icons.calculate),
            Paragraph(
              '通过实现 __add__（+）、__sub__（-）、__mul__（*）等魔术方法，'
              '让自定义类型的运算像数学表达式一样自然。',
            ),
            CodeBlock(
              r'''class Vector:
    def __init__(self, x, y):
        self.x, self.y = x, y

    def __add__(self, other):           # v1 + v2
        return Vector(self.x + other.x, self.y + other.y)

    def __sub__(self, other):           # v1 - v2
        return Vector(self.x - other.x, self.y - other.y)

    def __mul__(self, n):               # v * n
        return Vector(self.x * n, self.y * n)

    def __rmul__(self, n):              # n * v
        return self.__mul__(n)

    def __neg__(self):                  # -v
        return Vector(-self.x, -self.y)

    def __abs__(self):                  # abs(v)
        return (self.x**2 + self.y**2) ** 0.5

    def __str__(self):
        return f"V({self.x},{self.y})"

v1 = Vector(3, 4)
v2 = Vector(1, 2)
print(f"{v1} + {v2} = {v1 + v2}")
print(f"{v1} - {v2} = {v1 - v2}")
print(f"{v1} * 3 = {v1 * 3}")
print(f"3 * {v1} = {3 * v1}")
print(f"-{v1} = {-v1}")
print(f"|{v1}| = {abs(v1):.2f}")
''',
              language: 'Python',
            ),
            OutputBox(
              'V(3,4) + V(1,2) = V(4,6)\n'
              'V(3,4) - V(1,2) = V(2,2)\n'
              'V(3,4) * 3 = V(9,12)\n'
              '3 * V(3,4) = V(9,12)\n'
              '-V(3,4) = V(-3,-4)\n'
              '|V(3,4)| = 5.00',
            ),
            TipBox(
              '__rmul__ 处理 3 * v：当 v.__mul__(3) 类型不匹配时，'
              'Python 尝试对方 __rmul__。对加法同理：__add__ 返回 NotImplemented 时尝试 __radd__。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ===== 12. 鸭子类型 =====
            SectionHeader('鸭子类型', icon: Icons.pets),
            Paragraph(
              '"如果它走起来像鸭子、叫起来像鸭子，那它就是鸭子。"'
              'Python 不检查对象类型，只关心它有没有需要的方法。这是多态的灵活体现。',
            ),
            CodeBlock(
              r'''class Duck:
    def sound(self): return "嘎嘎嘎！"

class Person:
    def sound(self): return "我假装是鸭子"

class Robot:
    def sound(self): return "哔哔-鸭子模式"

def make_sound(thing):
    """不关心类型，只关心有没有 sound() 方法"""
    print(thing.sound())

make_sound(Duck())     # 嘎嘎嘎！
make_sound(Person())   # 我假装是鸭子
make_sound(Robot())    # 哔哔-鸭子模式

# 实用例子：统一接口
class FileReader:
    def read(self): return "文件数据"
class DBReader:
    def read(self): return "数据库数据"

def process(reader):
    """任何有 read() 的对象都能传入"""
    print(f"处理: {reader.read()}")

process(FileReader())
process(DBReader())
''',
              language: 'Python',
            ),
            OutputBox(
              '嘎嘎嘎！\n'
              '我假装是鸭子\n'
              '哔哔-鸭子模式\n'
              '处理: 文件数据\n'
              '处理: 数据库数据',
            ),
            TipBox(
              '鸭子类型让代码非常灵活，但错误可能运行时才暴露。'
              '静态类型检查（mypy）和抽象基类（ABC）可以弥补这个缺点。',
              type: TipType.warning,
            ),
            DividerLine(),

            // ===== 小练习 =====
            SectionHeader('小练习', icon: Icons.edit_note),
            StepItem(
              step: 1,
              title: '定义一个"手机"类',
              description: '包含 brand、price 属性，call(name) 方法，以及 __str__ 显示品牌和价格。',
            ),
            StepItem(
              step: 2,
              title: '继承练习',
              description: '定义 Shape 抽象基类（area / perimeter），Circle 和 Rectangle 子类实现。',
            ),
            StepItem(
              step: 3,
              title: '运算符重载',
              description: '写一个 Vector 类，实现 __add__、__mul__、__abs__，让向量运算像数学表达式。',
            ),
            StepItem(
              step: 4,
              title: 'dataclass 应用',
              description: '用 @dataclass 定义 Order 类，实现 __post_init__ 自动计算总价。',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
