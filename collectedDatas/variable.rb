require_relative "inferable"
class Variable < BasicData
  include Inferable
  attr_reader :name
  attr_accessor :hasGetter, :hasSetter
  def initialize(rbfile, line, exp, name)
    super(rbfile, line, exp)
    initInferableModule()
    @name = name
    @hasGetter = false
    @hasSetter = false
  end

  def onReceiveNotification(obj)
    addAllInfer(obj.infers)
  end

  def to_s
    return @name
  end

  def printCollectedData()
    return "#{@name} #{printInferData}"
  end
end