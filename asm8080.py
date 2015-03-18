destinations = {'b':0b0,'c':0b1000,'d':0b10000,'e':0b11000,'h':0b100000,
                'l':0b101000,'m':0b110000,'a':0b111000,'psw':0b110000,
                'sp':0b110000}

sources = {'b':0b0,'c':0b1,'d':0b10,'e':0b11,'h':0b100,'l':0b101,'m':0b110,
           'a':0b111}

Instr = Instruction

instructions = [Instruction("mov",0x40,Instr.DEST_SRC|Instr.REG_OP),
                Instruction("mvi",0x06,Instr.DEST|Instr.REG_OP),
                Instruction("lxi",0x01,Instr.DEST_IMM_16|Instr.SP_OP|Instr.PAIR),
                Instruction("stax",

ERR_INVALID_OPERAND = 1
ERR_MISSING_OPERAND = 2
ERR_UNDEFINED_OPERAND = 3
ERR_UNDEFINED_INSTR = 4
ERR_INVALID_LABEL = 5
ERR_UNDEFINED_LABEL = 6
ERR_INVALID_CONST = 7
ERR_UNDEFINED_CONST = 8

def error(msg,code=0,fail=True):
    print ("ASM ERROR %d - %s %d: %s" % (code,filename,lineno,msg)).upper()
    if fail:
        print "ASSEMBLY FAILED"
        exit()
    return

def parse_int8(n):

    value = 0
    
    if n.endswith("h"):
        value = int(n[:-1], 16)

    elif n.endswith("b"):
        value = int(n[:-1], 1)

    elif n.endswith("o"):
        value = int(n[:-1], 8)

    else:
        try:
            value = int(n)
        except:
            error("'%s' is not a valid constant." % ERR_UNDEFINED_CONST)

    if value > 255:
        error("'%s' is not within 8-bit range." % n, ERR_INVALID_CONST)

    return value

def parse_int16(n):

    value = 0
    
    if n.endswith("h"):
        value = int(n[:-1], 16)

    elif n.endswith("b"):
        value = int(n[:-1], 1)

    elif n.endswith("o"):
        value = int(n[:-1], 8)

    else:
        try:
            value = int(n)
        except:
            error("'%s' is not a valid constant." % ERR_UNDEFINED_CONST)

    if value > 65535:
        error("'%s' is not within 8-bit range." % n, ERR_INVALID_CONST)

    return value

class Instruction:

    # Different catagories of instructions
    # 1 - no operands
    # 2 - dest,source instruction
    # 3 - dest only
    # 4 - src only
    # 5 - 8-bit immidiate only
    # 6 - 16-bit immidiate only
    # 7 - dest and 8-bit immidiate
    # 8 - dest and 16-bit immidiate
    
    NO_OPERANDS = 0
    DEST_SRC    = 1
    DEST        = 2
    SRC         = 3
    IMM_8       = 4
    IMM_16      = 5
    DEST_IMM_8  = 6
    DEST_IMM_16 = 7

    REG_OP = 0b01000
    PSW_OP = 0b10000
    SP_OP  = 0b11000
    
    def __init__(self, name, binary, catagory):
        self.name = name
        self.catagory = catagory
        self.opcode = binary

    def isMatch(self, name):
        return True if (self.name == name) else False

    def get_src(self, src):

        try:
            return sources[src]

        except:
            error("'%s' is an undefined source." % src, ERR_UNDEFINED_OPERAND)

    def _get_dest(self, dest):

        try:
            return destinations[dest]

        except:
            error("'%s' is an undefined destination." % dest, ERR_UNDEFINED_OPERAND)

    def get_dest(self, dest):

        t = self.catagory & 0b11000

        if t == self.REG_OP:
            if dest in ("sp","psw"):
                error("'%s' is not a valid destination for '%s'." % (dest,self.name), ERR_INVALID_OPERAND)

        elif t == PSW_OP:
            if dest == "sp":
                error("'sp' is not a valid destination for '%s'." % self.name, ERR_INVALID_OPERAND)
            if dest in ("a","c","e","l","m"):
                error("'%s' is not a valid register pair." % dest, ERR_INVALID_OPERAND)

        elif t == SP_OP:
            if dest == "psw":
                error("'psw' is not a valid destination for '%s'." % self.name, ERR_INVALID_OPERAND)
            if dest in ("a","c","e","l","m"):
                error("'%s' is not a valid register pair." % dest, ERR_INVALID_OPERAND)

        return self._get_dest(dest) 
            

    def assemble(self, (dest,src)):

        value = [self.binary]

        cat = self.catagory & 0b111
        
        if not cat and (dest or src):     # instruction doesn't take any operands
            error("'%s' takes no operands." % self.name, ERR_INVALID_OPERAND)

        elif cat == DEST_SRC:
            if not dest or not src:
                error("'%s' requires two operands." % self.name, ERR_MISSING_OPERAND)
            value[0] |= self.get_dest(dest) | self.get_src(src)
        elif cat == DEST:
            if not dest:
                error("'%s' requires one operand." % self.name, ERR_MISSING_OPERAND)
            value[0] |= self.get_dest(dest)
        elif cat == SRC:
            if not dest:
                error("'%s' requires one operand." % self.name, ERR_MISSING_OPERAND)
            value[0] |= self.get_src(dest)
        elif cat == IMM_8:
            if not dest:
                error("'%s' requires one operand." % self.name, ERR_MISSING_OPERAND)
            value.extend(parse_int8(dest))
        elif cat == IMM_16:
            if not dest:
                error("'%s' requires one operand." % self.name, ERR_MISSING_OPERAND)
            value.extend(parse_int16(dest))
        elif cat == DEST_IMM_8:
            if not dest or not src:
                error("'%s' requires two operands." % self.name, ERR_MISSING_OPERAND)
            value[0] |= self.get_dest(dest)
            value.extend(parse_int8(src))
        elif cat == DEST_IMM_16:
            if not dest or not src:
                error("'%s' requires two operands." % self.name, ERR_MISSING_OPERAND)
            value[0] |= self.get_dest(dest)
            value.extend(parse_int16(src))
        return value
            
