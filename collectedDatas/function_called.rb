require_relative "inferable"
require_relative "discovered_classes"
require_relative "infer_data"
require_relative "object_instance"
class FunctionCalled < BasicData
  include Inferable
  attr_reader :methodName

  def initialize(rbfile, line, exp, methodName, parameters)
    super(rbfile, line, exp)
    initInferableModule()
    @methodName = methodName
    @parameters = parameters
  end

  def onReceiveNotification(obj)
    addAllInfer(obj.infers)
  end

  def getParameter(index)
    if(index >= 0 && index < @parameters.size)
      return @parameters[index]
    end
    return nil
  end

  def inferNativeFunction(baseInfer)
    if(@methodName == :new && !baseInfer.isObjectInstance?)
      instance = ObjectInstance.new(baseInfer.value)
      addAllInfer(instance.infers)
    elsif(@methodName == :class && baseInfer.isObjectInstance?)
      selfType = SelfInstance.new(baseInfer.type)
      addAllInfer(selfType.infers)
    elsif((@methodName == :each || @methodName == :[]) && baseInfer.isFromArray?)
      addAllInfer(baseInfer.obj.infersOnEach)
    end
  end

  def infer(infers)
    infers.each do |baseInfer|
      if(baseInfer.type == :Class)
        clazz = DiscoveredClasses.instance.getClassByFullName(baseInfer.value)
      else
        clazz = DiscoveredClasses.instance.getClassByFullName(baseInfer.type)
      end
      if(!clazz.nil?)
        if(baseInfer.obj.class != ConstCall)
          method = clazz.getInstanceMethodByName(@methodName)
        else
          method = clazz.getStaticMethodByName(@methodName)
        end
        if(!method.nil?)
          method.addListener(self)
          parameterIndex = 0
          @parameters.each do |parameter|
            formalParameter = method.getFormalParameter(parameterIndex)
            if(!formalParameter.nil?)
              parameter.addListener(formalParameter)
            end
            parameterIndex += 1
          end
        else
          inferNativeFunction(baseInfer)
        end
      else
        inferNativeFunction(baseInfer)
      end
    end
  end


  def to_s
    str = "#{@methodName}("
    @parameters.each do |param|
      str = "#{str}#{param.to_s},"
    end
    if(@parameters.size > 0)
      str.chop!
    end
    str = "#{str})"
    return str
  end

  def parameters_to_s(init)
    str = ""
    for i in init..@parameters.size - 1
      str = "#{@parameters[i].to_s},"
    end
    str.chop!
    return str
  end
  def printCollectedData()
    str = "#{@methodName}("
    @parameters.each do |param|
      str = "#{str}#{param.printCollectedData()},"
    end
    if(@parameters.size > 0)
      str.chop!
    end
    str = "#{str})"
    return str
  end
end