# This file is part of the multiple_attachment module for Tryton.
# The COPYRIGHT file at the top level of this repository contains the full
# copyright notices and license terms.
import hy
from trytond.pool import Pool
from . import attachment

def register():
    Pool.register(
        attachment.AttachmentPurgatory,
        attachment.Attachment,
        module='attachment_cleaner', type_='model')
    
