; -*- Mode: Lisp; Package: editor -*-

#|
= windzoom - �E�B���h�E�̕������A�j���[�V�����������

* Authror:  miyamuko ((<URL:mailto:miyamuko@gmail.com>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/windzoom/intro.htm>))
* Version: $Id: windzoom.l,v 1.9 2004/08/09 17:43:54 miyamuko Exp $


== ����

((%C-x 2%)) �� ((%C-x 3%)) �ł̃E�B���h�E�������ɃA�j���[�V�������܂��B

* ((<URL:http://heimat.jp/~nakaji/elips/20030502/4956.html>)) ��
  xyzzy �ɈڐA�������̂ł��B
* �u�~���[���v�Ƃ����Ȃ���g�����̂������ł��B


== �C���X�g�[��

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) �ŃC���X�g�[�������ꍇ�� 3 �ȍ~���A
NetInstaller + (({ni-autoload})) ���g���Ă���l�� 4 �ȍ~�� OK �ł��B

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/windzoom.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(3) ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; windzoom
        (require "windzoom")

(4) �ݒ�𔽉f������ɂ� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B


== ���t�@�����X

=== �L�[���蓖��

((%C-x 0%))�A((%C-x 1%))�A((%C-x 2%))�A((%C-x 5%))
���A�j���[�V����������悤�ɍĐݒ肵�Ă��܂��B


== �o������

* undo �p�� window-configuration ��ۑ����Ă��A�폜���� window ��
  set-window-configuration �ł͕����ł��Ȃ��̂�undo �͖��T�|�[�g�B


== ���C�Z���X

�I���W�i���� windzoom.el �ɏ]���܂��B

|#

;;; windzoom.el --- Window manipulation with continuous visual feeback
;;                 or real world killer application of zooming interface
;;
;; Copyright (C) 2003-2004 Masatake YAMATO
;;
;; Author: Masatake YAMATO <jet@gyve.org>
;; Created: Thu May  1 19:55:05 2003
;; Keywords: window, visual feeback, zooming, focus
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:
;; This program is for our wedding memorial and her birthday.

;;; Code:

(provide "windzoom")
(in-package "editor")

(export '(windzoom-delete-window
          windzoom-delete-other-windows
          windzoom-split-window
          windzoom-split-window-vertically))

;; key
(define-key ctl-x-map #\0 'windzoom-delete-window)
(define-key ctl-x-map #\1 'windzoom-delete-other-windows)
(define-key ctl-x-map #\2 'windzoom-split-window)
(define-key ctl-x-map #\5 'windzoom-split-window-vertically)

;; ----------------------------------------------------------------------
(defvar *windzoom-interval* 0
  "Value passed to sit-for during zooming.")

(defvar *windzoom-enlarge-size* 3
  "Value passed to enlarge-window during zooming.")

;; ----------------------------------------------------------------------
(defun windzoom-one-window-p ()
  (interactive)
  (= 1 (count-windows)))

;; window-height ���g���Ȃ��̂� window-coordinate �ő�p
(defun windzoom-height (&optional (window (selected-window)))
  (- (nth 3 (window-coordinate window))
     (nth 1 (window-coordinate window))))

;; ----------------------------------------------------------------------
; windzoom-focus-out
(defun windzoom-delete-window ()
  (interactive)

  ;; calc shrink direction
  (labels ((calc-shrink-direction ()
             (let (alt-win alt-win-h)
               (save-window-excursion
                 (delete-window)
                 (setf alt-win (selected-window))
                 (setf alt-win-h (windzoom-height)))
               (= (windzoom-height alt-win) alt-win-h))))
    (let ((vertical (calc-shrink-direction)))
      (while (ignore-errors (enlarge-window
                             (- *windzoom-enlarge-size*) vertical))
        (sit-for *windzoom-interval*))))
  (delete-window))

; windzoom-focus-in
(defun windzoom-delete-other-windows ()
  (interactive)

  (let ((current (selected-window)))
    (while (not (windzoom-one-window-p))
      (other-window (random (count-windows)))
      (unless (eq current (selected-window))
        (windzoom-delete-window)))))

; windzoom-split-window-vertically
(defun windzoom-split-window (&optional arg vertical)
  (interactive "p")

  (split-window arg vertical)
  (let (window-stack)
    ;; record
    (push (current-window-configuration) window-stack)
    (save-window-excursion
      (while (ignore-errors (enlarge-window
                             (- *windzoom-enlarge-size*) vertical))
        (push (current-window-configuration) window-stack)))
    ;; replay
    (while window-stack
      (set-window-configuration (pop window-stack))
      (sit-for *windzoom-interval*))))

; windzoom-split-window-horizontally
(defun windzoom-split-window-vertically (&optional arg)
  (interactive "p")
  (windzoom-split-window arg t))