#!/usr/bin/env python3
"""
PDFファイルから画像を抽出するスクリプト

使用方法:
    python extract_pdf_images.py <pdf_path> [output_dir]

必要なライブラリ:
    pip install PyMuPDF Pillow
"""

import sys
import os
from pathlib import Path
import fitz  # PyMuPDF


def extract_images_from_pdf(pdf_path: str, output_dir: str = None):
    """
    PDFファイルから画像を抽出する
    
    Args:
        pdf_path: PDFファイルのパス
        output_dir: 出力ディレクトリ（指定しない場合はPDFと同じディレクトリに作成）
    """
    # PDFファイルの存在確認
    if not os.path.exists(pdf_path):
        print(f"エラー: PDFファイルが見つかりません: {pdf_path}")
        sys.exit(1)
    
    # 出力ディレクトリの設定
    if output_dir is None:
        pdf_name = Path(pdf_path).stem
        output_dir = os.path.join(os.path.dirname(pdf_path), f"{pdf_name}_images")
    
    # 出力ディレクトリの作成
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"PDFファイル: {pdf_path}")
    print(f"出力ディレクトリ: {output_dir}")
    print("-" * 50)
    
    # PDFを開く
    pdf_document = fitz.open(pdf_path)
    image_count = 0
    
    # 各ページを処理
    for page_num in range(len(pdf_document)):
        page = pdf_document[page_num]
        print(f"ページ {page_num + 1}/{len(pdf_document)} を処理中...")
        
        # ページ内の画像リストを取得
        image_list = page.get_images(full=True)
        
        # 各画像を抽出
        for img_index, img in enumerate(image_list):
            xref = img[0]  # 画像のXREF番号
            
            try:
                # 画像データを取得
                base_image = pdf_document.extract_image(xref)
                image_bytes = base_image["image"]
                image_ext = base_image["ext"]
                
                # ファイル名を生成
                image_filename = f"page{page_num + 1:03d}_img{img_index + 1:03d}.{image_ext}"
                image_path = os.path.join(output_dir, image_filename)
                
                # 画像を保存
                with open(image_path, "wb") as image_file:
                    image_file.write(image_bytes)
                
                image_count += 1
                print(f"  ✓ 保存: {image_filename} ({len(image_bytes)} bytes)")
                
            except Exception as e:
                print(f"  ✗ エラー: ページ {page_num + 1}, 画像 {img_index + 1}: {e}")
    
    pdf_document.close()
    
    print("-" * 50)
    print(f"完了: {image_count} 個の画像を抽出しました")
    print(f"保存先: {output_dir}")


def main():
    """メイン関数"""
    if len(sys.argv) < 2:
        print("使用方法: python extract_pdf_images.py <pdf_path> [output_dir]")
        print("\n例:")
        print("  python extract_pdf_images.py document.pdf")
        print("  python extract_pdf_images.py document.pdf ./output_images")
        sys.exit(1)
    
    pdf_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None
    
    extract_images_from_pdf(pdf_path, output_dir)


if __name__ == "__main__":
    main()
