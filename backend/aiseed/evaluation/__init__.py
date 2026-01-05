"""
評価モジュール

AIバージョンとルールベースバージョンを並行開発・評価するための基盤

開発フロー:
1. AIバージョンでシナリオ開発
2. パターンを抽出してルールベース実装
3. AIテスターで評価
4. 改善を繰り返す
"""
from .compare import ResponseComparer
from .tester import AITester
from .patterns import PatternExtractor

__all__ = ["ResponseComparer", "AITester", "PatternExtractor"]
